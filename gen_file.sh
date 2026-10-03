#!/usr/bin/env bash

set -e

ORG_FILE="gallery.org"
IMAGE_DIR="assets/images/lowell_youth_wrestling_2025_2026"
WEB_IMAGE_DIR="/assets/images/lowell_youth_wrestling_2025_2026"

TMP_FILE="${ORG_FILE}.tmp"

awk -v image_dir="$IMAGE_DIR" -v web_dir="$WEB_IMAGE_DIR" '
BEGIN {
    in_gallery = 0
    gallery_started = 0
}

# Find the season heading
/^\* 2025-2026 Season$/ {
    print
    print ""
    print "#+begin_export html"
    print "<div style=\"position:relative; max-width:100%; margin:auto; text-align:center;\">"
    print ""
    print "  <img id=\"gallery-image\""
    
    # Find images
    cmd = "find \"" image_dir "\" -maxdepth 1 -type f -name \"*_n.jpg\" -printf \"%f\\n\" | sort -V"

    first = 1

    while ((cmd | getline image) > 0) {
        if (first) {
            print "       src=\"" web_dir "/" image "\""
            first = 0
        }
    }

    close(cmd)

    print "       style=\"width:100%; height:auto;\">"
    print ""
    print "  <button onclick=\"previousImage()\""
    print "          style=\"position:absolute; left:10px; top:50%; transform:translateY(-50%); font-size:30px; padding:10px 15px;\">"
    print "    &#10094;"
    print "  </button>"
    print ""
    print "  <button onclick=\"nextImage()\""
    print "          style=\"position:absolute; right:10px; top:50%; transform:translateY(-50%); font-size:30px; padding:10px 15px;\">"
    print "    &#10095;"
    print "  </button>"
    print ""
    print "</div>"
    print ""
    print "<script>"
    print "const galleryImages = ["

    # Find images again for the Javascript array
    cmd = "find \"" image_dir "\" -maxdepth 1 -type f -name \"*_n.jpg\" -printf \"%f\\n\" | sort -V"

    first = 1

    while ((cmd | getline image) > 0) {
        if (first) {
            printf "  \"%s/%s\"", web_dir, image
            first = 0
        } else {
            printf ",\n  \"%s/%s\"", web_dir, image
        }
    }

    close(cmd)

    print ""
    print "];"
    print ""
    print "let currentImage = 0;"
    print ""
    print "function showImage(index) {"
    print "  currentImage = (index + galleryImages.length) % galleryImages.length;"
    print "  document.getElementById(\"gallery-image\").src = galleryImages[currentImage];"
    print "}"
    print ""
    print "function previousImage() {"
    print "  showImage(currentImage - 1);"
    print "}"
    print ""
    print "function nextImage() {"
    print "  showImage(currentImage + 1);"
    print "}"
    print "</script>"
    print "#+end_export"
    print ""

    in_gallery = 1
    gallery_started = 1
    next
}

# Skip everything from the old 2025-2026 content
# until the next top-level Org heading.
/^\* / && in_gallery {
    in_gallery = 0
    print
    next
}

in_gallery {
    next
}

{
    print
}
' "$ORG_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$ORG_FILE"

echo "Gallery updated."
