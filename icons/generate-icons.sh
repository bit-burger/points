#!/usr/bin/env bash

# generate the app icons (ios, android),
# as well as the splash screen (ios, android, web)

# convert cmd tool by imagemagick has to be installed
# and the 'Courier' font has to be installed


if ! command -v convert &> /dev/null
then
    echo "'convert' is not installed" && exit 1
fi

echo "generating the .pngs..."
convert -background transparent logo-with-text.svg logo-with-text-clear.png
convert -background transparent logo-smaller.svg logo-clear.png
convert -background \#DDE6E8 logo-smaller.svg logo-filled.png
echo "successfully generated .pngs"

echo ""

echo "updating the splash screens and app icons..."
flutter pub run flutter_native_splash:create &> /dev/null &
  flutter pub run flutter_launcher_icons:main &> /dev/null
echo "successfully updated the splash screens and app icons"
