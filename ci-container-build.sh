#!/usr/bin/env bash
# ==============================================================================
# ApexOS — Container Bootstrap Script for GitHub Actions (archlinux:latest)
# Bootstraps Arch + x86-64-v3 optimized repos & keys inside the CI container,
# copies the profile into /tmp/apexos-profile (never touches /build/.git!),
# builds AUR packages as non-root 'builder', and runs mkarchiso.
# ==============================================================================

set -euo pipefail

echo "=== [CI 1/5] Initializing Arch keyring & base build tools ==="
cat > /etc/pacman.d/mirrorlist <<'EOF'
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
EOF

pacman-key --init
pacman-key --populate archlinux

# Enable multilib in the container host pacman.conf
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
  printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
fi

pacman -Syyu --noconfirm
pacman -S --noconfirm --needed \
  archiso \
  base-devel \
  git \
  curl \
  sudo \
  rsync \
  pacman-contrib \
  dosfstools \
  mtools \
  squashfs-tools \
  libisoburn \
  erofs-utils

echo "=== [CI 2/5] Bootstrapping x86-64-v3 repository GPG key & mirrorlists ==="
pacman-key --recv-keys F3B607488DB35A47 --keyserver hkps://keyserver.ubuntu.com \
  || pacman-key --recv-keys F3B607488DB35A47 --keyserver hkps://keys.openpgp.org \
  || pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key F3B607488DB35A47

# Seed initial x86-64-v3 mirrorlists so pacman can install the latest official mirrorlist & keyring packages
cat > /etc/pacman.d/cachyos-mirrorlist <<'EOF'
Server = https://mirror.cachyos.org/repo/$arch/$repo
Server = https://cdn77.cachyos.org/repo/$arch/$repo
EOF

cat > /etc/pacman.d/cachyos-v3-mirrorlist <<'EOF'
Server = https://mirror.cachyos.org/repo/x86_64_v3/$repo
Server = https://cdn77.cachyos.org/repo/x86_64_v3/$repo
EOF

if ! grep -q '^\[cachyos\]' /etc/pacman.conf; then
  cat >> /etc/pacman.conf <<'EOF'

[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-extra-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
EOF
fi

# Allow stock Arch pacman in the CI container to install x86_64_v3 optimized packages
sed -i 's/^Architecture = .*/Architecture = x86_64 x86_64_v3/' /etc/pacman.conf

# Install the latest official x86-64-v3 keyring & mirrorlist packages (--overwrite avoids conflict with seeded files)
pacman -Sy --noconfirm --overwrite '*' cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist
pacman-key --populate archlinux cachyos

echo "=== [CI 3/5] Creating non-root 'builder' user & isolated profile workspace ==="
if ! id -u builder >/dev/null 2>&1; then
  useradd -m -G wheel -s /bin/bash builder
fi
echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-ci-builder
chmod 440 /etc/sudoers.d/99-ci-builder

# Copy profile into /tmp so we NEVER modify ownership of /build/.git on the GitHub runner!
PROFILE_TMP="/tmp/apexos-profile"
rm -rf "${PROFILE_TMP}"
mkdir -p "${PROFILE_TMP}"
rsync -a \
  --exclude='.git' \
  --exclude='work' \
  --exclude='out' \
  --exclude='release-assets' \
  /build/ "${PROFILE_TMP}/"

chmod +x "${PROFILE_TMP}/build-iso.sh" "${PROFILE_TMP}/profiledef.sh"
chown -R builder:builder "${PROFILE_TMP}"

echo "=== [CI 4/5] Running ApexOS build-iso.sh ==="
su - builder -c "cd '${PROFILE_TMP}' && ./build-iso.sh"

echo "=== [CI 5/5] Copying finished ISO to /build/out ==="
mkdir -p /build/out
cp -v "${PROFILE_TMP}"/out/*.iso /build/out/
chmod -R a+rwX /build/out
