#!/bin/bash
set -Eeuo pipefail

mkdir -p target

is_installed () {
  dpkg-query -l "$1" | grep '^ii' >/dev/null
}

echo "Installing JRE..."
if ! ((is_installed default-jre || is_installed default-jre-headless) \
    && is_installed libegl1 && is_installed libopengl0 && is_installed libxcb-cursor0); then
  sudo apt-get update
  sudo apt-get install -y default-jre libegl1 libopengl0 libxcb-cursor0
fi

echo "Installing Calibre..."
is_installed calibre || (wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin)

echo "Downloading epubcheck..."
curl -L "https://github.com/w3c/epubcheck/releases/download/v$EPUBCHECK_VERSION/epubcheck-$EPUBCHECK_VERSION.zip" -o "target/epubcheck-$EPUBCHECK_VERSION.zip"
unzip -o "./target/epubcheck-$EPUBCHECK_VERSION.zip" -d "./target"
mv "./target/epubcheck-$EPUBCHECK_VERSION" "./target/epubcheck"

EBGARAMOND_FONT_DIR="/usr/share/fonts/truetype/custom/EB_Garamond"
if [ -d "$EBGARAMOND_FONT_DIR" ]; then
  echo "EB Garamond font already installed"
else
  echo "Downloading EB Garamond..."
  curl -L "https://github.com/octaviopardo/EBGaramond12/archive/refs/heads/master.zip" -o "target/EB_Garamond.zip"
  unzip -o "./target/EB_Garamond.zip" -d "./target/EB_Garamond"

  echo "Installing EB Garamond..."
  mkdir -p "/usr/share/fonts/truetype/custom/EB_Garamond"
  find "./target/EB_Garamond" -name "*.ttf" -exec mv '{}' "/usr/share/fonts/truetype/custom/EB_Garamond" \;
  fc-cache -f -v
fi

echo "Done."
