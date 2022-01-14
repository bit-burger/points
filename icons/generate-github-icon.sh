#!/usr/bin/env bash


if ! command -v convert &> /dev/null
then
    echo "'convert' is not installed" && exit 1
fi

convert -density 576 -background none -fill \#DDE6E8 logo.svg -opaque \#000000 ../.github/logo-white.png
mogrify -gravity Center -crop 80%x80% -resize 512x512 ../.github/logo-white.png