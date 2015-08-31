#!/bin/bash
echo 'Press ENTER to overwrite rc_nomargin.xml with a modified version of rc.xml'
echo 'sed: <top>13</top> -> <top>1</top>'
read
sed "s/<top>13<\/top>/<top>1<\/top>/g" rc.xml > rc_nomargin.xml
