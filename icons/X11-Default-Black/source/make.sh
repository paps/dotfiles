#!/bin/sh
if ! [ -x "$(command -v xcursorgen)" ]; then
echo "xcursorgen is not installed (part of \e[1;31mx11-apps\e[0m package in Devuan)"
return
fi
[ -d "../cursors" ] && rm -rf ../cursors ; mkdir ../cursors
xcursorgen hand2.in ../cursors/hand2
xcursorgen left_ptr.in ../cursors/left_ptr
xcursorgen wait.in ../cursors/wait
xcursorgen xterm.in ../cursors/xterm
xcursorgen context-menu.in ../cursors/context-menu
xcursorgen crossed_circle.in ../cursors/crossed_circle
xcursorgen right_ptr.in ../cursors/right_ptr
xcursorgen plus.in ../cursors/plus
xcursorgen dotbox.in ../cursors/dotbox
xcursorgen sb_h_double_arrow.in ../cursors/sb_h_double_arrow
xcursorgen sb_v_double_arrow.in ../cursors/sb_v_double_arrow
xcursorgen top_left_corner.in ../cursors/top_left_corner
xcursorgen top_right_corner.in ../cursors/top_right_corner
xcursorgen bottom_left_corner.in ../cursors/bottom_left_corner
xcursorgen bottom_right_corner.in ../cursors/bottom_right_corner
xcursorgen watch.in ../cursors/watch
xcursorgen sb_left_arrow.in ../cursors/sb_left_arrow
xcursorgen sb_right_arrow.in ../cursors/sb_right_arrow
xcursorgen sb_up_arrow.in ../cursors/sb_up_arrow
xcursorgen sb_down_arrow.in ../cursors/sb_down_arrow
xcursorgen based_arrow_down.in ../cursors/based_arrow_down
xcursorgen based_arrow_up.in ../cursors/based_arrow_up
xcursorgen fleur.in ../cursors/fleur
xcursorgen sizing.in ../cursors/sizing
xcursorgen question_arrow.in ../cursors/question_arrow
xcursorgen X_cursor.in ../cursors/X_cursor
xcursorgen zoom-in.in ../cursors/zoom-in
xcursorgen zoom-out.in ../cursors/zoom-out
xcursorgen pencil.in ../cursors/pencil
xcursorgen cell.in ../cursors/cell
xcursorgen grabbing.in ../cursors/grabbing
xcursorgen grab.in ../cursors/grab
ln -s hand2 ../cursors/hand1
ln -s grab ../cursors/openhand
ln -s wait ../cursors/progress
ln -s wait ../cursors/00000000000000020006000e7e9ffc3f
ln -s wait ../cursors/08e8e1c95fe2fc01f976f1e063a24ccd
ln -s wait ../cursors/3ecb610c1bf2410f44200f48c40d3599
ln -s left_ptr ../cursors/top_left_arrow
ln -s right_ptr ../cursors/arrow
ln -s right_ptr ../cursors/draft_large
ln -s right_ptr ../cursors/draft_small
ln -s sb_v_double_arrow ../cursors/double_arrow
ln -s sb_v_double_arrow ../cursors/top_side
ln -s sb_v_double_arrow ../cursors/bottom_side
ln -s sb_h_double_arrow ../cursors/left_side
ln -s sb_h_double_arrow ../cursors/right_side
ln -s cell ../cursors/target
ln -s X_cursor ../cursors/pirate
[ -d "../cursors" ] && echo "Cursors generation to $(readlink -f ../cursors) complete. \e[1;32mHave fun ;)\e[0m"
