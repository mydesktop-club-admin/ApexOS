#!/usr/bin/env bash
# ==============================================================================
# ApexOS KDE Desktop Theme Packager
# Run this on the Linux PC that has your favorite KDE Plasma theme/dock/widgets.
# It packages ONLY your active theme, icons, cursors, window decorations,
# widgets, and sanitized panel layout into ONE file:
#   ~/apexos-theme-bundle.tar.zst
#
# Drop that single file into the root of your ApexOS GitHub repo and run
# "Build ApexOS ISO" — build-iso.sh automatically extracts it into the ISO!
# ==============================================================================

set -euo pipefail

STAGE="/tmp/apexos-theme-stage"
OUT_FILE="${HOME}/apexos-theme-bundle.tar.zst"

rm -rf "${STAGE}"
mkdir -p \
  "${STAGE}/usr/share/icons" \
  "${STAGE}/usr/share/color-schemes" \
  "${STAGE}/usr/share/aurorae/themes" \
  "${STAGE}/usr/share/plasma/desktoptheme" \
  "${STAGE}/usr/share/plasma/look-and-feel" \
  "${STAGE}/usr/share/plasma/plasmoids" \
  "${STAGE}/etc/skel/.config"

copy_if_found() {
  local src="$1"
  local dst="$2"
  if [[ -e "${src}" ]]; then
    echo "  + Bundling: ${src}"
    cp -a "${src}" "${dst}/"
  fi
}

echo "=== [1/4] Collecting active icons & cursors ==="
for icon in Mkos-Big-Sur-Night Mkos-Big-Sur Mkos-Big-Sur-Panel-white Apple-cursors; do
  if [[ -d "${HOME}/.local/share/icons/${icon}" ]]; then
    copy_if_found "${HOME}/.local/share/icons/${icon}" "${STAGE}/usr/share/icons"
  elif [[ -d "/usr/share/icons/${icon}" ]]; then
    copy_if_found "/usr/share/icons/${icon}" "${STAGE}/usr/share/icons"
  fi
done

echo "=== [2/4] Collecting active color scheme, Plasma style, Aurorae & Global Theme ==="
copy_if_found "${HOME}/.local/share/color-schemes/MkosBigSurDark.colors" "${STAGE}/usr/share/color-schemes"
copy_if_found "${HOME}/.local/share/aurorae/themes/Mkos-BigSur-Night" "${STAGE}/usr/share/aurorae/themes"
copy_if_found "${HOME}/.local/share/plasma/desktoptheme/AppleDark-ALL" "${STAGE}/usr/share/plasma/desktoptheme"
copy_if_found "${HOME}/.local/share/plasma/look-and-feel/popky2" "${STAGE}/usr/share/plasma/look-and-feel"

echo "=== [3/4] Collecting ONLY your 7 active Plasma widgets ==="
for plasmoid in \
  luisbocanegra.panel.colorizer \
  Plasma.AppBay \
  Plasma.Flex.Hub \
  org.kde.plasma.clearclock \
  org.kde.windowtitle.Fork \
  zayron.simple.separator \
  com.github.zren.commandoutput; do
  if [[ -d "${HOME}/.local/share/plasma/plasmoids/${plasmoid}" ]]; then
    copy_if_found "${HOME}/.local/share/plasma/plasmoids/${plasmoid}" "${STAGE}/usr/share/plasma/plasmoids"
  elif [[ -d "/usr/share/plasma/plasmoids/${plasmoid}" ]]; then
    copy_if_found "/usr/share/plasma/plasmoids/${plasmoid}" "${STAGE}/usr/share/plasma/plasmoids"
  fi
done

echo "=== [4/4] Collecting & sanitizing KDE configs for /etc/skel/.config ==="
for cfg in \
  kdeglobals \
  kcminputrc \
  kwinrc \
  plasmarc \
  plasmashellrc \
  plasma-org.kde.plasma.desktop-appletsrc \
  kdedefaults; do
  copy_if_found "${HOME}/.config/${cfg}" "${STAGE}/etc/skel/.config"
done

# Include Panel Colorizer custom presets if saved in ~/.config/panel-colorizer
copy_if_found "${HOME}/.config/panel-colorizer" "${STAGE}/etc/skel/.config"

# Sanitize personal home paths so the layout works for ANY user account on ApexOS
for f in "${STAGE}/etc/skel/.config/plasmarc" "${STAGE}/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc" "${STAGE}/etc/skel/.config/kdeglobals"; do
  [[ -f "$f" ]] || continue
  sed -i "s|${HOME}/.local/share/|/usr/share/|g" "$f"
  sed -i '/^usersWallpapers=/d' "$f"
  sed -i 's|^Image=file://.*|Image=/usr/share/wallpapers/ApexOS/contents/images/3840x2160.jpg|' "$f"
  sed -i "s|${HOME}/Pictures/[^,]*|/usr/share/wallpapers/ApexOS/contents/images/3840x2160.jpg|g" "$f"
done

# Ensure Panel Colorizer presets also use generic system paths if any exist
if [[ -d "${STAGE}/etc/skel/.config/panel-colorizer" ]]; then
  find "${STAGE}/etc/skel/.config/panel-colorizer" -type f -exec sed -i "s|${HOME}/.local/share/|/usr/share/|g" {} + || true
fi

# Pack with maximum zstd compression; auto-split at 20 MB if over GitHub's 25 MB web upload cap
rm -f "${OUT_FILE}" "${OUT_FILE}".part*
tar -I 'zstd -19 -T0' -cf "${OUT_FILE}" -C "${STAGE}" .
rm -rf "${STAGE}"

SIZE_BYTES=$(stat -c%s "${OUT_FILE}")
if (( SIZE_BYTES > 24 * 1024 * 1024 )); then
  split -b 20M -d -a 2 "${OUT_FILE}" "${OUT_FILE}.part"
  rm -f "${OUT_FILE}"
  echo ""
  echo "================================================================"
  echo "  Created split bundle parts (under GitHub's 25 MB web limit):"
  ls -lh "${OUT_FILE}".part*
  echo "  Upload all .part* files into the root of your ApexOS GitHub repo"
  echo "  and run 'Build ApexOS ISO'!"
  echo "================================================================"
else
  echo ""
  echo "================================================================"
  echo "  Created: ${OUT_FILE}"
  ls -lh "${OUT_FILE}"
  echo "  Upload this single file into the root of your ApexOS GitHub repo"
  echo "  and run 'Build ApexOS ISO'!"
  echo "================================================================"
fi
