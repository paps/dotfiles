---
name: apt-upgrade-report
description: Analyse pending apt upgrades on a Debian or Debian-derived system and report them as a categorised, annotated listing (kernel/boot, system, browsers & editors, user applications, libraries/modules, others) plus kept-back packages, a plain-`apt upgrade` delta, a short summary and recommendations. Use when asked what an upgrade will do, what will change, whether it is safe to upgrade, or for a review of pending package updates.
---

# apt upgrade report

Produce a human-readable analysis of what a `apt full-upgrade` would do on this
machine, without changing anything.

**This skill is read-only, unconditionally.** It never modifies the machine —
not `apt update`, `apt upgrade`, `apt full-upgrade`, `apt install`,
`apt autoremove`, `dpkg -i`, nor anything else that mutates package state — and
that holds **even if the user asks for it while the skill is running**. Such a
request is a separate task: finish or abandon the report, then handle it outside
this skill. Every command below is a simulation or a query.

Do not reach for `sudo` to work around this. Everything the report needs runs as
an ordinary user, and privileged commands are assumed to prompt for a password
the agent cannot supply anyway.

## 1. Preconditions

Check these first, in order, and stop at the first failure.

**Is this an apt system?** If `apt-get` is absent or `/etc/os-release` shows a
non-Debian-derived distro, say so plainly and stop. Do not improvise with
another package manager.

**Is the package list fresh?** The analysis is worthless against a stale cache,
so require an update within the last **6 hours**.

```sh
# primary signal: apt writes into this directory on every successful update
stat -c %Y /var/lib/apt/lists
# fallback if that directory is missing
stat -c %Y /var/cache/apt/pkgcache.bin
date +%s
```

Prefer the `lists` directory mtime — `pkgcache.bin` is also rebuilt by
install/remove operations, so it can look fresh without anything having been
fetched. If the newest available signal is more than 21600 seconds old, **refuse
the analysis** and stop. Report the actual age and ask the user to run:

```sh
sudo apt update
```

then invoke the skill again. Do not run it yourself, do not offer to, and do not
fall back to analysing the stale data anyway.

## 2. Scan the machine

Do this before the simulations — the context decides which findings matter and
what the recommendations should say. Never assume a hardware platform, a
bootloader, or a repository set; detect them.

The commands below are **suggestions, not a checklist**. They cover the usual
ground, but use your own judgement: skip what is irrelevant to the machine in
front of you, substitute better tools where they exist, and dig further whenever
something looks unusual. What matters is arriving at the understanding described
after the block, not running these exact lines.

```sh
cat /etc/os-release                       # distro and suite
dpkg --print-architecture
cat /etc/apt/sources.list 2>/dev/null; cat /etc/apt/sources.list.d/*  # repos in use
apt-cache policy                          # priorities, NotAutomatic suites, pins
cat /etc/apt/preferences /etc/apt/preferences.d/* 2>/dev/null
uname -r                                  # running kernel
dpkg -l 'linux-image*' | grep '^ii'       # installed kernels
apt-mark showhold                         # held packages
dpkg -l | awk 'NR>5 && $1 != "ii"'        # broken / half-configured / residual
df -h / /boot /var
systemd-detect-virt 2>/dev/null           # bare metal, VM, or container
dpkg -l needrestart 2>/dev/null | tail -1 # will service restarts be prompted?
```

Also identify the boot path, since kernel and bootloader findings hang off it —
check for whichever of these exist: `/boot/grub/grub.cfg`, `/boot/loader/`
(systemd-boot), `/boot/efi/EFI/`, `/boot/extlinux/`, an EFI system partition,
u-boot or platform/board firmware packages, and `efibootmgr` output. A container
or an image built without a kernel has no boot path at all; say so rather than
inventing one.

Note anything that changes the reading:

- Third-party repositories, and which packages come from them.
- Suites at a non-default priority (experimental, backports, `NotAutomatic`
  sources) — call out whether anything is actually being pulled from them.
- Pins, holds, and packages in a broken or half-configured state.
- Free space against the estimated download and install size.

## 3. Simulate

The report is **always** about `full-upgrade`. Run that first:

```sh
apt-get -s full-upgrade
```

Then, for the delta section only, simulate what plain `apt upgrade` would do.
Note the trap: `apt upgrade` is **not** `apt-get upgrade` — apt adds
`--with-new-pkgs`, so it does install new packages while still refusing to
remove any. Model it correctly:

```sh
apt-get -s upgrade --with-new-pkgs
```

Parse the machine-readable action lines rather than the prose summary:

- `Inst <pkg> [<old>] (<new> …)` — an upgrade, `old → new`.
- `Inst <pkg> (<new> …)` with no `[...]` — a **new** package.
- `Remv <pkg> [<ver>]` — a **removed** package.

Estimate the total download size by summing the `Size:` fields:

```sh
apt-cache --no-all-versions show <all packages in the Inst list> | awk '/^Size: /{s+=$2} END {print s}'
```

For per-package sizes — needed for the `[BIG …]` tag in §5 — parse `apt-cache
show` in paragraph mode so each package's fields stay together:

```sh
apt-cache --no-all-versions show <packages> | awk 'BEGIN{RS="";FS="\n"}
  {p=s="";
   for(n=1;n<=NF;n++){
     if($n ~ /^Package: /) p=substr($n,10);
     else if($n ~ /^Size: /) s=substr($n,7)}
   if(p && s) print s"\t"p}' | sort -rn
```

Do not try to pair `Package:` and `Size:` with a line-at-a-time script that
flushes on a guessed delimiter — field order and the set of fields present vary
between packages, and the values silently end up attached to the wrong names.
Sanity-check the result: if a small utility appears among the largest packages,
the parse is wrong, not the archive.

If nothing is upgradable, say so in one line and stop — no categories, no
summary.

## 4. Categorise

Assign **every** changed package (upgraded, new, and removed) to exactly one of
these six categories. The per-category totals must add up to the total number
of changes; verify this before writing the report.

| Category | What goes in it |
|---|---|
| **Kernel / boot** | Kernel images, headers, `linux-libc-dev`, kernel metapackages, out-of-tree/DKMS modules, initramfs generators, bootloaders, EFI shims and boot managers, platform/board firmware and early-boot loaders, device firmware blobs, CPU microcode |
| **System** | Core OS plumbing and privileged infrastructure: the C library, init and service manager, apt/dpkg, coreutils and util-linux, PAM and login, filesystem tools, system daemons and services (network, remote access, printing, storage, discovery), display/compositor servers, container and VM runtimes |
| **Browsers & editors** | The two things most likely to be open and in use while the upgrade runs, and the ones most disruptive to replace underneath the user. Browsers: the browser itself plus its `-common`/`-sandbox`/`-l10n` companions, ESR and beta variants, driver and policy packages, extensions; text-mode browsers count. Editors: terminal editors, GUI editors and IDEs, and editors built on an embedded browser engine |
| **User applications** | Everything else a person invokes: mail clients, office suites, media players, terminal tools, language interpreters and compilers, VCS clients |
| **Libraries / modules** | Shared libraries, `-dev` packages, language-binding modules (`python3-*`, `perl` modules, `gir1.2-*`), plugin sets, graphics/driver userspace |
| **Others** | Data-only packages: fonts, icons, themes, GSettings schemas, locale and dictionary data, documentation, registries and config-only packages. Also the catch-all: anything that does not clearly belong to one of the five categories above goes here rather than being forced into a poor fit |

Judgement calls, resolved consistently:

- A shell that is essential to the boot/script path belongs to **system**; a
  shell installed as a user's interactive login shell belongs to **user
  applications**.
- Compilers and interpreters are **user applications**; their runtime libraries
  are **libraries / modules**.
- A daemon and its client tools go together in **system**, even when part of the
  set is library packages.
- An embedded browser engine does not by itself put a package in **browsers &
  editors** — what matters is whether the thing is a browser or an editor. An
  Electron code editor belongs there; a desktop chat or AI client does not. A
  mail client is a **user application** even when built on a browser engine.
- Browser and editor *engine* libraries stay in **libraries / modules**. When
  one moves, cross-reference it on the application's line, since it is usually
  the reason that application moved.

## 5. Report

Write the report to the user directly. Structure:

**Preamble** — two or three lines: distro/suite, architecture, how fresh the
package lists are, total counts (upgraded / new / removed), estimated download
size, and free space. Flag immediately if space is tight or the system is in a
broken dpkg state.

**One block per category**, in the order: kernel/boot, system, browsers &
editors, user applications, libraries/modules, others. Each block is a fenced
code block by default — see §6 before styling it — one package per line:

```
<package name>        <old version> → <new version>   <optional few-word note>
<package name>        (none) → <version>              [NEW]  <optional note>
<package name>        <version> → (none)              [REMOVED]  <optional note>
<package name>        <old version> → <new version>   [BIG 345 MB]  <optional note>
```

Rules for these lines:

- List only the **important** changes, one per line. A change is important when
  it crosses a real upstream version boundary, is security-sensitive, affects
  something the user interacts with daily, runs as a service that will need
  restarting, is an ABI/soname transition, or is a package appearing or
  disappearing from the system. A pure Debian rebuild (`+b1` → `+b2`) or a
  packaging-revision bump is *not* important unless the package is critical, in
  which case list it and annotate it `rebuild only`.
- Some categories will legitimately have no important changes. That is fine —
  go straight to the residual line.
- **Always** mark new packages `[NEW]` and removed packages `[REMOVED]`. These
  are never folded into the residual line, however dull, because they change
  what exists on the machine.
- Mark any package whose **download size is 10 MB or more** with
  `[BIG <n> MB]`, rounded to whole megabytes. Download size is the `Size:`
  field from `apt-cache show`, not `Installed-Size:`. Package sizes are
  steeply skewed — a typical upgrade set has a median well under 1 MB and a
  handful of outliers carrying most of the bytes — so even at this threshold
  the tag lands on only a small minority of packages while accounting for most
  of the download. On a small upgrade nothing will qualify, which is itself
  useful information; do not lower the bar further to produce hits.
- On a collapsed family line, apply the threshold to the **family total**, not
  to individual members, and report that total. A large suite is often dozens
  of moderate packages with no single one over the bar, and it would otherwise
  go unmarked despite being the biggest thing in the upgrade.
- Collapse families into a single line with a `(+N)` count — e.g. an office
  suite or a Qt stack — and name the family's headline package. The collapsed
  packages still count toward the category total.
- The note is a few words at most, and only when it adds something the version
  numbers do not: what will break, what needs a restart, why the package
  appeared, what pulled it in.
- Close every block with exactly one residual line:

```
N others — notably <pkg> <old>→<new>, <pkg> <old>→<new>, <pkg> <old>→<new>
```

  where N is the count of that category's changes not already listed above, and
  the three named are the most interesting of the remainder (biggest version
  jump, most user-visible, or most surprising). If N is 0, write
  `no other changes` instead.

**Kept back** — a short section. List the packages `full-upgrade` refuses to
touch and, more usefully, diagnose *why*. The common causes are an ABI or
time64-style transition that would require removals, a pin or hold, a
dependency not yet built, or a conflict with something installed. Say whether
forcing it through (`apt install <pkgs>`) is advisable given the machine's role
and boot path — a held-back bootloader or filesystem tool on a machine that
boots from it is worth leaving alone until the user is ready. Omit the section
entirely if nothing is kept back.

**If you run `apt upgrade` instead** — a short section giving the counts for
plain `apt upgrade` and, concretely, which packages differ from the
`full-upgrade` set and why (`apt upgrade` never removes a package, so anything
requiring a removal gets deferred). If the two are identical, say so in one
line.

**Summary** — a few sentences in your own words. What is the character of this
upgrade: routine point releases, a toolchain or library transition, a kernel
move, a mix? What is the single riskiest thing in it? Keep it succinct; do not
restate the lists.

**Recommendations** — at most a handful of short bullets, and only where there
is something real to say: what to close or stop first, whether a reboot is
needed, what to do about kept-back packages, whether anything should be dealt
with separately rather than in the batch, and what to check afterwards. If the
upgrade is unremarkable, say that in one line instead of padding the list.

## 6. Presentation

This report is dense — several long lists plus prose. Where the harness can
render them, use **colour and bold accents to make it scannable**. They are a
readability tool, never decoration.

**First, work out what the harness can actually render.** Rendered markdown
means emphasis works in prose but *not* inside fenced code blocks. A terminal
that honours ANSI escapes means colour is available. A plain-text channel, a
file, or a piped destination means no styling at all. When you cannot tell,
assume less rather than more.

**Styling is additive.** Strip every escape and marker and the report must lose
nothing. Never carry meaning in colour alone — that is exactly why `[NEW]`,
`[REMOVED]` and `[BIG …]` stay as literal text, and why counts, sizes and
versions are always spelled out. Someone reading a copy-pasted plain-text
version should get the same report.

**Keep the palette small and consistent** — at most three or four roles, each
meaning the same thing everywhere in the report:

- one accent for additions (`[NEW]`)
- one for removals (`[REMOVED]`)
- one for attention: reboot required, low disk space, a kept-back package with
  boot impact, the riskiest item in the summary
- default colour for everything else, which will be most of it

Prefer the terminal's standard palette over hardcoded RGB so the user's theme
stays in charge, and avoid shades that disappear against either a light or a
dark background.

**Use bold sparingly.** Emphasis every third line reads the same as no emphasis
at all. Reserve it for section headings, total counts in the preamble, the
package name on the handful of lines that genuinely matter most, and the single
riskiest item named in the summary. Do not colour whole lines or whole blocks,
and do not style version numbers as a class — they are the bulk of the text.

**Alignment beats colour.** The version columns do a lot of the readability work
in the category blocks. If styling is only available outside fenced blocks, and
removing the fence would let the renderer collapse the whitespace and break the
columns, keep the fence and leave the block unstyled. Style the prose sections
instead, where emphasis works and alignment is not at stake.

## Notes

- `apt-get -s` runs fine as a normal user and prints a "this is only a
  simulation" banner; that banner is expected and not a problem.
- `systemd-detect-virt` exits non-zero when it prints `none`. That means bare
  metal, not a failed command.
- Report what the simulation actually says. If apt's resolver produces something
  you did not expect, investigate it rather than smoothing it over — an odd
  resolution is usually the most interesting finding in the whole report.
- Autoremovable packages listed by apt are worth a mention in recommendations,
  but never advise running `apt autoremove` before the user has booted and
  verified a new kernel.
