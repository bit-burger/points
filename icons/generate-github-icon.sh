#!/usr/bin/env bash


if ! command -v convert &> /dev/null
then
    echo "'convert' is not installed" && exit 1
fi

convert -density 576 -background none -fill \#DDE6E8 logo.svg -opaque \#000000 ../.github/logo-white.png
mogrify -blur 0x2 ../.github/logo-white.png