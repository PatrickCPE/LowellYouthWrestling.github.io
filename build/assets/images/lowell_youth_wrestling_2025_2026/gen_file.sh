#!/usr/bin/env bash

ORG_FILE="gallery.org"
IMAGE_DIR="."

awk -v image_dir="$IMAGE_DIR" '
    BEGIN {
        in_gallery = 0
    }

    /^\* 2025-2026 Season$/ {
        in_gallery = 1
        print
        next
    }

    in_gallery && /^To be updated!$/ {
        print
        print ""

        cmd = "find \"" image_dir "\" -maxdepth 1 -type f -name \"*_n.jpg\" -printf \"%f\\n\" | sort -V"

        while ((cmd | getline image) > 0) {
            print "#+begin_export html"
            print "<center>"
            print "<img src=\"/assets/images/" image "\" style=\"width:100%;height:100%\">"
            print "</center>"
            print "#+end_export"
            print ""
        }

        close(cmd)
        in_gallery = 0
        next
    }

    { print }
' "$ORG_FILE" > "$ORG_FILE.tmp"

mv "$ORG_FILE.tmp" "$ORG_FILE"
