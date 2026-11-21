#!/usr/bin/env bash
# ApexOS — Archiso Profile Definition (Arch x86-64-v3 + NVIDIA + KDE Plasma)

iso_name="ApexOS"
iso_label="APEXOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="ApexOS / mydesktop.club <https://mydesktop.club>"
iso_application="ApexOS Gaming Live/Install Medium (NVIDIA + KDE Plasma)"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=(
  'bios.syslinux'
  'uefi.systemd-boot'
)
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '12' '-b' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-15')

file_permissions=(
  ["/root"]="0:0:750"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/mydesktop-club-app"]="0:0:755"
  ["/usr/local/bin/apexos-game-launch"]="0:0:755"
  ["/usr/local/bin/apexos-firstboot"]="0:0:755"
  ["/usr/local/bin/apexos-welcome"]="0:0:755"
  ["/usr/local/bin/apexos-updater"]="0:0:755"
  ["/usr/local/bin/apexos-do-update"]="0:0:755"
  ["/usr/local/bin/apexos-layout-switcher"]="0:0:755"
)
