#!/bin/sh
emacs -Q --script build-site.el
cp assets build/ -r
