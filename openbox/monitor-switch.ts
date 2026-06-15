#!/usr/bin/env -S npx tsx
/**
 * monitor-switch.ts — stay sane switching between single-monitor (laptop only)
 * and dual-monitor (laptop + external on the right) on X11 / Openbox.
 *
 * Run with:   npx tsx monitor-switch.ts <single|dual> [--dry-run]
 *
 * ─────────────────────────────────────────────────────────────────────────────
 * MENTAL MODEL
 *
 * In this X11 setup both monitors are "viewports onto one big framebuffer".
 * The laptop panel maps the left region of that framebuffer; the external
 * monitor maps the region immediately to its right. Crucially, the framebuffer
 * does NOT shrink when the external monitor is unplugged — the pixels (and the
 * windows sitting on them) stay exactly where they were, just off-screen to the
 * right. So we can always reason about two rectangles inside one big plane:
 *
 *     +----------------+---------------------------+
 *     |                |                           |
 *     |   LAPTOP       |        EXTERNAL           |
 *     |   (0,0,Wl,Hl)  |   (Wl,0,Wfb-Wl,Hfb)       |
 *     |                |                           |
 *     +----------------+---------------------------+
 *
 * MODES
 *   dual   : all windows live on the "Primary" desktop; a window's X position
 *            decides whether it's shown on the laptop (left) or external (right).
 *   single : windows that used to live on the external monitor have been moved
 *            to the "Secondary" desktop and rescaled to fit the laptop panel, so
 *            you can flip between Primary (native laptop windows) and Secondary
 *            (formerly-external windows) with the desktop switcher.
 *
 * SWITCHING (stateless, proportional)
 *   dual -> single : take Primary windows whose centre is in the external region,
 *                    rescale them proportionally into the laptop region, and park
 *                    them on the Secondary desktop.
 *   single -> dual : take every window on Secondary, rescale it proportionally
 *                    into the external region, and move it back to Primary.
 *
 * Scaling is proportional to each region's width/height, so a window keeps the
 * same relative position and size ratio on its new screen.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { execFileSync } from "node:child_process";

// ── Config ──────────────────────────────────────────────────────────────────

const PRIMARY_DESKTOP_NAME = "Primary";
const SECONDARY_DESKTOP_NAME = "Secondary";

// ── Tiny shell helpers (no shell, no injection) ─────────────────────────────

function run(cmd: string, args: string[]): string {
  return execFileSync(cmd, args, { encoding: "utf8" });
}

/** Run a command, returning "" on failure instead of throwing. */
function tryRun(cmd: string, args: string[]): string {
  try {
    return run(cmd, args);
  } catch {
    return "";
  }
}

function requireBinary(name: string): void {
  if (!tryRun("which", [name]).trim()) {
    fail(`required tool "${name}" not found in PATH`);
  }
}

function fail(msg: string): never {
  console.error(`monitor-switch: ${msg}`);
  process.exit(1);
}

// ── Geometry types ──────────────────────────────────────────────────────────

interface Rect {
  x: number;
  y: number;
  w: number;
  h: number;
}

interface Layout {
  lap: Monitor; // full laptop monitor region in framebuffer coords
  lapWork: Rect; // usable laptop region (top panel strut removed)
  ext: Monitor; // full external region in framebuffer coords (true xrandr coords)
  extWork: Rect; // usable external region (top panel strut removed)
}

interface Win {
  id: string; // 0x.... window id
  desktop: number; // -1 == sticky/all
  geom: Rect; // FRAME-outer rect in true root coords (decorations included)
  frame: FrameExtents; // _NET_FRAME_EXTENTS captured at read time
  cls: string; // WM_CLASS
  title: string;
}

// ── Reading the X11 layout ──────────────────────────────────────────────────

interface Monitor extends Rect {
  name: string;
}

/**
 * Parse the viewport geometry (WxH+X+Y) of every output with an active CRTC
 * from full `xrandr` output, e.g.:
 *   eDP-1 connected primary 2560x1600+0+0 (normal ...) 344mm x 215mm
 *   DP-1  connected 3840x2160+2560+60 (normal ...) 600mm x 340mm
 * xrandr keeps reporting an output's position/size even while it's unplugged
 * (until its CRTC is reconfigured), so this is the single source of truth for
 * monitor geometry — we never derive it from the framebuffer or anything else.
 */
function readMonitors(): Monitor[] {
  const out = run("xrandr", []);
  const mons: Monitor[] = [];
  for (const line of out.split("\n")) {
    if (/^\s/.test(line)) continue; // indented lines are mode lists, skip
    const m = line.match(/(\d+)x(\d+)\+(\d+)\+(\d+)/);
    if (!m) continue; // output with no active CRTC (off / no geometry)
    mons.push({
      name: line.split(/\s+/)[0],
      w: Number(m[1]),
      h: Number(m[2]),
      x: Number(m[3]),
      y: Number(m[4]),
    });
  }
  return mons;
}

/**
 * Determine the laptop and external regions, both straight from xrandr.
 * Laptop = leftmost viewport; external = the nearest viewport fully to its
 * right. We require BOTH to exist with sensible relative coordinates and error
 * out otherwise — no fallbacks, no guessing.
 */
function readLayout(): Layout {
  const monitors = readMonitors();
  const describe = () =>
    monitors.map((r) => `${r.name} ${r.w}x${r.h}+${r.x}+${r.y}`).join(", ") ||
    "(none)";

  if (monitors.length < 2) {
    fail(
      `expected 2 monitors with viewport geometry from xrandr, found ${monitors.length}: ${describe()}\n` +
        "  xrandr should keep reporting an unplugged monitor's position until its\n" +
        "  CRTC is reconfigured. If a monitor is missing here, fix the display\n" +
        "  config (don't let it get torn down) and retry.",
    );
  }

  const sorted = [...monitors].sort((a, b) => a.x - b.x);
  const lap = sorted[0];
  const ext = sorted.find((r) => r.x >= lap.x + lap.w);
  if (!ext) {
    fail(
      "no external monitor positioned to the right of the laptop.\n" +
        `  monitors: ${describe()}`,
    );
  }

  // Openbox is configured to reserve a band at the top of the framebuffer. (for polybar etc)
  // _NET_WORKAREA's y is that band's height (the root window origin is 0,0).
  // We clip BOTH monitors' tops against it so a window flush to the strut on
  // one screen maps flush to the strut on the other — see usableRegion().
  const wa = readWorkArea();
  if (!wa) {
    fail("could not read EWMH work area (_NET_WORKAREA) from `wmctrl -d`");
  }
  const strutTop = wa.y;
  const lapWork = usableRegion(lap, strutTop);
  const extWork = usableRegion(ext, strutTop);
  if (lapWork.h <= 0 || extWork.h <= 0) {
    fail("a monitor's usable region is empty after removing the top panel strut");
  }
  return { lap, lapWork, ext, extWork };
}

/** Read the EWMH work area (_NET_WORKAREA) via the `WA:` field of `wmctrl -d`. */
function readWorkArea(): Rect | null {
  const out = tryRun("wmctrl", ["-d"]);
  for (const line of out.split("\n")) {
    // "0  * DG: 3840x1600  VP: 0,0  WA: 0,60 3840x1540  Primary"
    const m = line.match(/WA:\s*(-?\d+),(-?\d+)\s+(\d+)x(\d+)/);
    if (m) {
      return { x: Number(m[1]), y: Number(m[2]), w: Number(m[3]), h: Number(m[4]) };
    }
  }
  return null;
}

/**
 * The usable part of a monitor after removing the top panel strut: we raise the
 * top to the strut bottom and shrink the height to match. We clip ONLY the top,
 * never the sides or bottom — _NET_WORKAREA is a single screen-wide rectangle,
 * so on a taller external monitor intersecting with it would spuriously chop
 * pixels off the bottom. This assumes the only strut is a top panel (polybar);
 * a bottom/side panel would need this extended.
 */
function usableRegion(monitor: Rect, strutTop: number): Rect {
  const top = Math.max(monitor.y, strutTop);
  return {
    x: monitor.x,
    y: top,
    w: monitor.w,
    h: monitor.h - (top - monitor.y),
  };
}

// ── Desktops ────────────────────────────────────────────────────────────────

/** Map desktop name -> index from `wmctrl -d`. */
function readDesktops(): Map<string, number> {
  const out = run("wmctrl", ["-d"]);
  const map = new Map<string, number>();
  for (const line of out.split("\n")) {
    // "0  * DG: 3840x1600  VP: 0,0  WA: 0,0 3840x1600  Primary"
    const m = line.match(/^(\d+)\s+.*?\s{2,}(\S.*)$/);
    if (m) map.set(m[2].trim(), Number(m[1]));
  }
  return map;
}

/** Ensure at least `n` desktops exist (Openbox starts with just Primary). */
function ensureDesktopCount(n: number): void {
  const have = run("wmctrl", ["-d"]).trim().split("\n").filter(Boolean).length;
  if (have < n) run("wmctrl", ["-n", String(n)]);
}

function desktopIndex(name: string, fallback: number): number {
  const idx = readDesktops().get(name);
  return idx ?? fallback;
}

// ── Windows ─────────────────────────────────────────────────────────────────

/** List manageable windows via `wmctrl -lGx`, filtering out panels/desktops. */
function listWindows(): Win[] {
  const out = run("wmctrl", ["-l", "-G", "-x"]);
  const wins: Win[] = [];
  for (const line of out.split("\n")) {
    if (!line.trim()) continue;
    // id  desktop  x  y  w  h  wm_class  client_machine  title...
    const m = line.match(
      /^(\S+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(.*)$/,
    );
    if (!m) continue;
    const desktop = Number(m[2]);
    if (desktop < 0) continue; // sticky / on-all-desktops — leave alone
    const id = m[1];
    if (isUnmanageableType(id)) continue;
    // `wmctrl -lG` reports `client + (left, top)` (it double-applies the border
    // offset), and `w,h` are the client size. Convert to the FRAME-outer rect in
    // true root coords so we lay out the whole visible window (titlebar incl.):
    //   frame.x = Rx - 2*left, frame.y = Ry - 2*top
    //   frame.w = Rw + left + right, frame.h = Rh + top + bottom
    const fe = frameExtents(id);
    const rx = Number(m[3]);
    const ry = Number(m[4]);
    const rw = Number(m[5]);
    const rh = Number(m[6]);
    wins.push({
      id,
      desktop,
      geom: {
        x: rx - 2 * fe.left,
        y: ry - 2 * fe.top,
        w: rw + fe.left + fe.right,
        h: rh + fe.top + fe.bottom,
      },
      frame: fe,
      cls: m[7],
      title: m[9],
    });
  }
  return wins;
}

/** Skip docks, panels, desktop backgrounds, splashes (polybar, conky, …). */
function isUnmanageableType(id: string): boolean {
  const out = tryRun("xprop", ["-id", id, "_NET_WM_WINDOW_TYPE"]);
  return /_NET_WM_WINDOW_TYPE_(DOCK|DESKTOP|SPLASH|TOOLBAR|MENU)/.test(out);
}

interface FrameExtents {
  left: number;
  right: number;
  top: number;
  bottom: number;
}

function frameExtents(id: string): FrameExtents {
  const out = tryRun("xprop", ["-id", id, "_NET_FRAME_EXTENTS"]);
  const m = out.match(/=\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)/);
  if (!m) return { left: 0, right: 0, top: 0, bottom: 0 };
  return {
    left: Number(m[1]),
    right: Number(m[2]),
    top: Number(m[3]),
    bottom: Number(m[4]),
  };
}

// ── The core proportional remap ─────────────────────────────────────────────

/** Map a rect from one region to another, keeping relative position + size. */
function remap(g: Rect, from: Rect, to: Rect): Rect {
  const fx = (g.x - from.x) / from.w;
  const fy = (g.y - from.y) / from.h;
  const fw = g.w / from.w;
  const fh = g.h / from.h;
  return {
    x: Math.round(to.x + fx * to.w),
    y: Math.round(to.y + fy * to.h),
    w: Math.max(1, Math.round(fw * to.w)),
    h: Math.max(1, Math.round(fh * to.h)),
  };
}

/** Do two rects overlap at all? */
function overlaps(a: Rect, b: Rect): boolean {
  return (
    a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y
  );
}

/**
 * Map a window's frame from its source region to the destination. Normally a
 * proportional remap, but a window sitting far outside the source region (e.g.
 * parked way off in X on the Secondary desktop) would extrapolate entirely
 * off-screen — so if the result wouldn't touch the destination monitor at all,
 * drop it at the destination's top-left (keeping its scaled size) and warn.
 */
function mapFrame(win: Win, from: Rect, to: Rect): Rect {
  const t = remap(win.geom, from, to);
  if (overlaps(t, to)) return t;
  console.log(
    `  warning: ${win.cls} "${win.title}" would map off-screen to ` +
      `(${t.x},${t.y} ${t.w}x${t.h}); placing at destination top-left ` +
      `(${to.x},${to.y}) instead`,
  );
  return { x: to.x, y: to.y, w: t.w, h: t.h };
}

function centreX(g: Rect): number {
  return g.x + g.w / 2;
}

// ── Applying a move ─────────────────────────────────────────────────────────

interface Plan {
  win: Win;
  target: Rect; // desired FRAME-outer rect in true root coords
  toDesktop: number;
}

function applyPlan(p: Plan, dryRun: boolean): void {
  const fe = p.win.frame;
  // `wmctrl -e` positions the FRAME outer top-left (x,y) but sizes the CLIENT
  // (w,h). So target frame -> write the frame position verbatim and subtract the
  // decorations to get the client size. Inverse of the read conversion in
  // listWindows(), making a round-trip drift-free.
  const x = p.target.x;
  const y = p.target.y;
  const w = Math.max(1, p.target.w - (fe.left + fe.right));
  const h = Math.max(1, p.target.h - (fe.top + fe.bottom));

  const geomArg = `0,${x},${y},${w},${h}`; // gravity 0 = use WM default

  {
    // Both sides shown as FRAME-outer rects (directly comparable for drift);
    // the actual client size written is `${w}x${h}`.
    const g = p.win.geom;
    const t = p.target;
    console.log(
      `${dryRun ? "[dry] " : ""}${p.win.cls.padEnd(24)} ` +
        `(${g.x},${g.y} ${g.w}x${g.h}) d${p.win.desktop}` +
        `  ->  (${t.x},${t.y} ${t.w}x${t.h}) d${p.toDesktop}` +
        `  [client ${w}x${h}]   ${p.win.title}`,
    );
  }
  if (dryRun) return;

  // Reposition first (geometry is retained across desktops), then move desktop.
  run("wmctrl", ["-i", "-r", p.win.id, "-e", geomArg]);
  if (p.win.desktop !== p.toDesktop) {
    run("wmctrl", ["-i", "-r", p.win.id, "-t", String(p.toDesktop)]);
  }
}

// ── Modes ───────────────────────────────────────────────────────────────────

function goSingle(dryRun: boolean): void {
  const layout = readLayout();
  if (!dryRun) ensureDesktopCount(2);

  const primary = desktopIndex(PRIMARY_DESKTOP_NAME, 0);
  const secondary = desktopIndex(SECONDARY_DESKTOP_NAME, 1);

  const plans: Plan[] = [];
  for (const win of listWindows()) {
    if (win.desktop !== primary) continue; // only act on Primary
    if (centreX(win.geom) < layout.ext.x) continue; // already on the laptop
    plans.push({
      win,
      // usable external region -> usable laptop region (both strut-clipped tops)
      target: mapFrame(win, layout.extWork, layout.lapWork),
      toDesktop: secondary,
    });
  }

  report("dual → single", plans.length, layout);
  if (plans.length === 0) {
    fail(
      "no windows found on the external monitor to move (Primary desktop, " +
        `centre X ≥ ${layout.ext.x}). Nothing to do.`,
    );
  }
  for (const p of plans) applyPlan(p, dryRun);
  if (!dryRun && plans.length) run("wmctrl", ["-s", String(primary)]);
}

function goDual(dryRun: boolean): void {
  const layout = readLayout();
  const primary = desktopIndex(PRIMARY_DESKTOP_NAME, 0);
  const secondary = desktopIndex(SECONDARY_DESKTOP_NAME, 1);

  const plans: Plan[] = [];
  for (const win of listWindows()) {
    if (win.desktop !== secondary) continue; // bring everything off Secondary
    plans.push({
      win,
      // usable laptop region -> usable external region; exact inverse of `single`
      target: mapFrame(win, layout.lapWork, layout.extWork),
      toDesktop: primary,
    });
  }

  report("single → dual", plans.length, layout);
  if (plans.length === 0) {
    fail(
      `no windows found on the ${SECONDARY_DESKTOP_NAME} desktop to move. Nothing to do.`,
    );
  }
  for (const p of plans) applyPlan(p, dryRun);
  if (!dryRun && plans.length) run("wmctrl", ["-s", String(primary)]);
}

function report(what: string, n: number, layout: Layout): void {
  console.log(
    `${what}: ${n} window(s)  ` +
      `| laptop ${layout.lap.name} usable ${layout.lapWork.w}x${layout.lapWork.h}` +
      `@${layout.lapWork.x},${layout.lapWork.y}` +
      ` | external ${layout.ext.name} usable ${layout.extWork.w}x${layout.extWork.h}` +
      `@${layout.extWork.x},${layout.extWork.y}`,
  );
}

// ── Entry point ─────────────────────────────────────────────────────────────

function main(): void {
  const argv = process.argv.slice(2);
  const mode = argv.find((a) => !a.startsWith("-"));
  const dryRun = argv.includes("--dry-run") || argv.includes("-n");

  if (mode !== "single" && mode !== "dual") {
    console.error(
      "usage: npx tsx monitor-switch.ts <single|dual> [--dry-run]\n" +
        "  single : park external-monitor windows on the Secondary desktop, fit to laptop\n" +
        "  dual   : bring Secondary windows back to Primary, out onto the external monitor",
    );
    process.exit(2);
  }

  for (const bin of ["xrandr", "wmctrl", "xprop"]) requireBinary(bin);

  if (mode === "single") goSingle(dryRun);
  else goDual(dryRun);
}

main();
