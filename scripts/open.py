#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import sys
import os
import subprocess

bindings = [
    # no extension
    ([""],
     ["gvim", "xdg-open", "geany", "gedit", "firefox", "google-chrome",
      "chromium-browser", "geeqie"]),
    # directory
    (["."],
     ["thunar", "pcmanfm", "gvim", "vlc", "geeqie"]),
    # image
    (["png", "jpg", "jpeg", "bmp", "gif", "eps", "ico", "ai"],
     ["geeqie", "eog", "feh", "gimp", "inkscape", "firefox", "google-chrome",
      "chromium-browser"]),
    # video
    (["avi", "mkv", "mp4", "3gp", "mov", "ogg"],
     ["vlc", "mplayer", "smplayer"]),
    # audio
    (["mp3", "wav", "flac", "aac", "aiff", "aifc", "aif", "ape"],
     ["vlc"]),
    # audio playlist
    (["pls"],
     ["vlc", "gvim", "geany", "gedit"]),
    # text
    (["txt", "cpp", "c++", "c", "cc", "h", "hpp", "h++", "py", "ada", "asc",
      "ash", "bat", "bf", "bi", "cas", "c86", "c--", "cap", "cls", "conf",
      "css", "cs", "csv", "cxx", "d", "desktop", "dev", "dif", "diff", "dmp",
      "e", "vim", "sh", "pl", "tex", "sample", "plt", "dat", "ini", "lua",
      "cfg", "pro", "ui", "cmake", "log", "php", "php4", "php5", "php6"],
     ["gvim", "geany", "gedit", "firefox", "google-chrome",
      "chromium-browser"]),
    # html
    (["htm", "html", "xhtml"],
     ["firefox", "google-chrome", "chromium-browser", "gvim", "geany",
      "gedit"]),
    # archives
    (["7z", "rar", "zip", "gz", "tar", "bz", "bz2", "ace", "ar7", "arc", "ark",
      "cab", "chz", "r00", "r01", "dwc", "cbr", "deb"],
     ["file-roller"]),
    # office
    (["doc", "docx", "docm", "xls", "xlsx", "ppt", "pptx", "dot", "dotx",
      "odt", "ods"],
     ["libreoffice", "openoffice.org"]),
    # pdf
    (["pdf"],
     ["evince", "gimp", "inkscape", "xpdf"]),
    # chm
    (["chm"],
     ["chmsee"]),
    # dia
    (["dia"],
     ["dia"]),
    # sqlite
    (["sqlite", "sqlite3"],
     ["sqlitebrowser"]),
]

def remove_duplicates(seq):
    seen = set()
    seen_add = seen.add
    return [x for x in seq if x not in seen and not seen_add(x)]

def get_menu_info(file_path):
    p = subprocess.Popen(["file", file_path], stdout=subprocess.PIPE)
    ret = p.wait()
    if not ret:
        return p.stdout.read()
    return ""

def whiptail(title, commands, file_path):
    res = ["whiptail", "--nocancel", "--title", title, "--menu", get_menu_info(file_path), "0", "0", "0"]
    for c in commands:
        res.append(c)
        res.append(file_path)
    return res

def get_menu_title(file_ext):
    if not len(file_ext):
        return "Opening file"
    elif file_ext == ".":
        return "Opening directory"
    else:
        return "Opening '%s' file" % file_ext

def get_commands(file_ext):
    for b in bindings:
        if file_ext in b[0]:
            return b[1]
    ret = []
    for b in bindings:
        for command in b[1]:
            ret.append(command)
    ret = remove_duplicates(ret)
    ret.sort()
    return ret

def fork_and_disown(program, args=""):
    command = program + " " + args + " 2> /dev/null > /dev/null & disown"
    subprocess.call(["bash", "-c", command])

def interactive_mode(file_path):
    if os.path.isfile(file_path):
        file_ext = os.path.splitext(file_path)[1][1:].strip().lower()
    elif os.path.isdir(file_path):
        file_ext = "."
    else:
        print("'%s' not found" % file_path)
        sys.exit()

    commands = get_commands(file_ext)
    title = get_menu_title(file_ext)

    #if len(commands) == 1:
    #    fork_and_disown(commands[0], "\"" + file_path + "\"")
    #else:
    p = subprocess.Popen(whiptail(title, commands, file_path), stderr=subprocess.PIPE)
    ret = p.wait()
    if not ret:
        selected = p.stderr.read().decode().strip()
        fork_and_disown(selected, "\"" + file_path + "\"")

def print_usage():
    print("Usage: open -i file")
    print("       open -f program")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print_usage()
        sys.exit()
    if len(sys.argv) < 3:
        sys.exit()
    if not len(sys.argv[1]) or not len(sys.argv[2]):
        print_usage()
        sys.exit()

    if sys.argv[1] == "-i":
        interactive_mode(sys.argv[2])
    elif sys.argv[1] == "-f":
        fork_and_disown(sys.argv[2])
    else:
        print_usage()
        sys.exit()
