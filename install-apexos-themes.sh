#!/usr/bin/env bash
# ==============================================================================
# Install ApexOS Dark & ApexOS Light KDE Plasma 6 Global Themes locally
# Usage:
#   ./install-apexos-themes.sh               # Install both themes for current user
#   ./install-apexos-themes.sh --apply dark  # Install & apply ApexOS Dark + left-aligned panel
#   ./install-apexos-themes.sh --apply light # Install & apply ApexOS Light + left-aligned panel
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${SCRIPT_DIR}/airootfs/usr/share"
DST="${HOME}/.local/share"

mkdir -p \
  "${DST}/color-schemes" \
  "${DST}/plasma/desktoptheme" \
  "${DST}/plasma/look-and-feel" \
  "${DST}/wallpapers" \
  "${DST}/icons/hicolor/scalable/apps"

echo "Installing ApexOS Dark & ApexOS Light KDE Plasma 6 Global Themes..."
cp -af "${SRC}/color-schemes/ApexOSDark.colors" "${DST}/color-schemes/"
cp -af "${SRC}/color-schemes/ApexOSLight.colors" "${DST}/color-schemes/"
cp -af "${SRC}/plasma/desktoptheme/ApexOSDark" "${DST}/plasma/desktoptheme/"
cp -af "${SRC}/plasma/desktoptheme/ApexOSLight" "${DST}/plasma/desktoptheme/"
cp -af "${SRC}/plasma/look-and-feel/org.apexos.dark" "${DST}/plasma/look-and-feel/"
cp -af "${SRC}/plasma/look-and-feel/org.apexos.light" "${DST}/plasma/look-and-feel/"
cp -af "${SRC}/wallpapers/ApexOSDark" "${DST}/wallpapers/"
cp -af "${SRC}/wallpapers/ApexOSLight" "${DST}/wallpapers/"
cp -af "${SRC}/pixmaps/apexos-welcome-icon.svg" "${DST}/icons/hicolor/scalable/apps/"

if [[ "${1:-}" == "--apply" ]]; then
  case "${2:-}" in
    dark)
      plasma-apply-lookandfeel -a org.apexos.dark --resetLayout
      plasma-apply-wallpaperimage "${DST}/wallpapers/ApexOSDark/contents/images/3840x2160.jpg" || true
      echo "Applied ApexOS Dark Global Theme!"
      ;;
    light)
      plasma-apply-lookandfeel -a org.apexos.light --resetLayout
      plasma-apply-wallpaperimage "${DST}/wallpapers/ApexOSLight/contents/images/3840x2160.jpg" || true
      echo "Applied ApexOS Light Global Theme!"
      ;;
    *)
      echo "Unknown theme '${2:-}'. Use 'dark' or 'light'." >&2
      exit 1
      ;;
  esac
else
  echo "Done! Open System Settings -> Colors & Themes -> Global Theme to choose:"
  echo "  - ApexOS Dark"
  echo "  - ApexOS Light"
fi
