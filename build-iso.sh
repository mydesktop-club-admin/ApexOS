#!/usr/bin/env bash
# ==============================================================================
# ApexOS ISO Builder — Run directly on Arch Linux
# Usage:
#   ./build-iso.sh
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_REPO_DIR="/tmp/apexos-local-repo"
AUR_BUILD_DIR="/tmp/apexos-aur-build"
WORK_DIR="${SCRIPT_DIR}/work"
OUT_DIR="${SCRIPT_DIR}/out"

echo "================================================================"
echo "  ApexOS Builder (Arch x86-64-v3 + NVIDIA + KDE Plasma)"
echo "================================================================"

if [[ $EUID -eq 0 ]]; then
  echo "Please run ./build-iso.sh as your normal user (not root)."
  echo "The script will ask for sudo only when running mkarchiso."
  exit 1
fi

# 1. Verify required tools on host machine
echo "[1/5] Checking host build dependencies..."
for cmd in mkarchiso makepkg repo-add git curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required tool: $cmd"
    echo "Install with: sudo pacman -S archiso base-devel git curl"
    exit 1
  fi
done

if [[ ! -f /etc/pacman.d/cachyos-v3-mirrorlist ]]; then
  echo "Warning: x86-64-v3 mirrorlist not found on host."
  echo "Make sure your host has x86-64-v3 repositories configured."
  exit 1
fi

# 2. Prepare local pacman repo for AUR packages (brave-bin)
echo "[2/5] Preparing local AUR repository at ${LOCAL_REPO_DIR}..."
rm -rf "${LOCAL_REPO_DIR}" "${AUR_BUILD_DIR}"
mkdir -p "${LOCAL_REPO_DIR}" "${AUR_BUILD_DIR}"

build_aur_pkg() {
  local pkg="$1"
  echo "  -> Building AUR package: ${pkg}"
  git clone --depth 1 "https://aur.archlinux.org/${pkg}.git" "${AUR_BUILD_DIR}/${pkg}"
  (
    cd "${AUR_BUILD_DIR}/${pkg}"
    makepkg -s --noconfirm --needed
    for f in ./*.pkg.tar.*; do
      [[ "$f" == *-debug-* ]] && continue
      cp -v "$f" "${LOCAL_REPO_DIR}/"
    done
  )
}

# Bundle Brave Browser into the ISO
build_aur_pkg "brave-bin"
repo-add "${LOCAL_REPO_DIR}/apexos-local.db.tar.gz" "${LOCAL_REPO_DIR}"/*.pkg.tar.*

# 3. Sync host x86-64-v3 & Arch mirrorlists into airootfs
echo "[3/5] Syncing x86-64-v3 & Arch mirrorlists into airootfs..."
mkdir -p "${SCRIPT_DIR}/airootfs/etc/pacman.d"
cp -f /etc/pacman.d/mirrorlist "${SCRIPT_DIR}/airootfs/etc/pacman.d/mirrorlist"
cp -f /etc/pacman.d/cachyos-mirrorlist "${SCRIPT_DIR}/airootfs/etc/pacman.d/cachyos-mirrorlist"
cp -f /etc/pacman.d/cachyos-v3-mirrorlist "${SCRIPT_DIR}/airootfs/etc/pacman.d/cachyos-v3-mirrorlist"

# Pre-flight filter: verify every package exists in the configured repos so typos/renames never abort mid-build
echo "[3.5/5] Verifying package manifest against configured repos..."
sudo pacman -Sy --config "${SCRIPT_DIR}/pacman.conf" --noconfirm >/dev/null
TMP_PKG_FILE="${SCRIPT_DIR}/.packages.x86_64.active"
: > "${TMP_PKG_FILE}"
while IFS= read -r line; do
  trimmed="$(echo "$line" | sed 's/#.*//' | xargs || true)"
  if [[ -z "${trimmed}" ]]; then
    continue
  fi
  if pacman --config "${SCRIPT_DIR}/pacman.conf" -Si "${trimmed}" >/dev/null 2>&1 || pacman --config "${SCRIPT_DIR}/pacman.conf" -Sg "${trimmed}" >/dev/null 2>&1; then
    echo "${trimmed}" >> "${TMP_PKG_FILE}"
  else
    echo "  [WARN] Package '${trimmed}' not found in configured repos — skipping."
  fi
done < "${SCRIPT_DIR}/packages.x86_64"

# Auto-verify NVIDIA kernel module & companion packages match nvidia-utils across repos
NV_VER=$(pacman --config "${SCRIPT_DIR}/pacman.conf" -Si nvidia-utils 2>/dev/null | awk '/^Version/ {print $3; exit}' | cut -d'-' -f1 | sed 's/^[0-9]*://')
NV_KMOD_REQ=$(pacman --config "${SCRIPT_DIR}/pacman.conf" -Si linux-cachyos-nvidia-open 2>/dev/null | grep -oE 'nvidia-utils=[0-9.:]+' | head -n1 | cut -d'=' -f2 | sed 's/^[0-9]*://' || true)
if [[ -n "${NV_KMOD_REQ}" && "${NV_KMOD_REQ}" != "${NV_VER}" ]]; then
  for repo in cachyos-v3 cachyos-extra-v3 cachyos extra; do
    REPO_NV=$(pacman --config "${SCRIPT_DIR}/pacman.conf" -Si "${repo}/nvidia-utils" 2>/dev/null | awk '/^Version/ {print $3; exit}' | cut -d'-' -f1 | sed 's/^[0-9]*://' || true)
    if [[ "${REPO_NV}" == "${NV_KMOD_REQ}" ]]; then
      echo "  [INFO] Pinning ${repo}/nvidia-utils (${REPO_NV}) to match NVIDIA kernel module."
      sed -i "s|^nvidia-utils$|${repo}/nvidia-utils|" "${TMP_PKG_FILE}"
      NV_VER="${REPO_NV}"
      break
    fi
  done
fi

if [[ -n "${NV_VER}" ]]; then
  for nvpkg in lib32-nvidia-utils opencl-nvidia nvidia-settings; do
    if grep -qx "${nvpkg}" "${TMP_PKG_FILE}"; then
      REQ_VER=$(pacman --config "${SCRIPT_DIR}/pacman.conf" -Si "${nvpkg}" 2>/dev/null | grep -oE 'nvidia-utils=[0-9.:]+' | head -n1 | cut -d'=' -f2 | sed 's/^[0-9]*://' || true)
      if [[ -n "${REQ_VER}" && "${REQ_VER}" != "${NV_VER}" ]]; then
        echo "  [WARN] Version skew: ${nvpkg} requires nvidia-utils=${REQ_VER}, but resolved nvidia-utils is ${NV_VER}."
        MATCHED=0
        for repo in cachyos-v3 cachyos-extra-v3 cachyos extra multilib; do
          if pacman --config "${SCRIPT_DIR}/pacman.conf" -Si "${repo}/${nvpkg}" 2>/dev/null | grep -q "nvidia-utils=${NV_VER}"; then
            echo "  [INFO] Pinning ${repo}/${nvpkg} to match nvidia-utils=${NV_VER}."
            sed -i "s|^${nvpkg}$|${repo}/${nvpkg}|" "${TMP_PKG_FILE}"
            MATCHED=1
            break
          fi
        done
        if [[ "${MATCHED}" == "0" ]]; then
          echo "  [WARN] No repo has ${nvpkg} matching nvidia-utils=${NV_VER} yet — skipping ${nvpkg} for this build."
          sed -i "/^${nvpkg}$/d" "${TMP_PKG_FILE}"
        fi
      fi
    fi
  done
fi

# 4. Stage active package list, relocate Calamares overlay to prevent pacman conflicts, and build ISO
echo "[4/5] Building bootable ApexOS ISO (this takes ~5-10 minutes)..."
cp "${SCRIPT_DIR}/packages.x86_64" "${SCRIPT_DIR}/.packages.x86_64.bak"
mv "${TMP_PKG_FILE}" "${SCRIPT_DIR}/packages.x86_64"

CALAMARES_STAGED=0
if [[ -d "${SCRIPT_DIR}/airootfs/etc/calamares" ]]; then
  echo "  -> Staging custom ApexOS Calamares config outside /etc/calamares to avoid package conflicts..."
  rm -rf "${SCRIPT_DIR}/airootfs/usr/share/apexos-calamares"
  mkdir -p "${SCRIPT_DIR}/airootfs/usr/share"
  mv "${SCRIPT_DIR}/airootfs/etc/calamares" "${SCRIPT_DIR}/airootfs/usr/share/apexos-calamares"
  CALAMARES_STAGED=1
fi

# Create one-shot ALPM hook so pacman applies our Calamares branding + live desktop setup right after pacstrap
mkdir -p "${SCRIPT_DIR}/airootfs/etc/pacman.d/hooks" "${SCRIPT_DIR}/airootfs/usr/local/bin"
cat > "${SCRIPT_DIR}/airootfs/usr/local/bin/apexos-post-pacstrap.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Overwrite default Calamares files with custom ApexOS branding & module configs
if [[ -d /usr/share/apexos-calamares ]]; then
  mkdir -p /etc/calamares
  cp -af /usr/share/apexos-calamares/. /etc/calamares/
  rm -rf /usr/share/apexos-calamares
fi

# Run live environment customization (locale, live user 'apex', SDDM, services, KDE theme)
if [[ -f /root/customize_airootfs.sh ]]; then
  for grp in wheel video audio input storage optical network gamemode; do
    groupadd -f "$grp" || true
  done
  bash /root/customize_airootfs.sh || true
fi

# Remove one-shot build hook and helper script
rm -f /etc/pacman.d/hooks/99-apexos-customize.hook /usr/local/bin/apexos-post-pacstrap.sh
EOF
chmod +x "${SCRIPT_DIR}/airootfs/usr/local/bin/apexos-post-pacstrap.sh"

cat > "${SCRIPT_DIR}/airootfs/etc/pacman.d/hooks/99-apexos-customize.hook" <<'EOF'
[Trigger]
Operation = Install
Type = Package
Target = cachyos-calamares
Target = sddm

[Action]
Description = Applying ApexOS Calamares branding and live desktop configuration...
When = PostTransaction
Exec = /bin/bash /usr/local/bin/apexos-post-pacstrap.sh
EOF

cleanup() {
  if [[ -f "${SCRIPT_DIR}/.packages.x86_64.bak" ]]; then
    mv -f "${SCRIPT_DIR}/.packages.x86_64.bak" "${SCRIPT_DIR}/packages.x86_64"
  fi
  if [[ "${CALAMARES_STAGED:-0}" == "1" && -d "${SCRIPT_DIR}/airootfs/usr/share/apexos-calamares" ]]; then
    mv "${SCRIPT_DIR}/airootfs/usr/share/apexos-calamares" "${SCRIPT_DIR}/airootfs/etc/calamares"
  fi
  rm -f "${SCRIPT_DIR}/airootfs/usr/local/bin/apexos-post-pacstrap.sh"
}
trap cleanup EXIT

sudo rm -rf "${WORK_DIR}"
mkdir -p "${OUT_DIR}"
sudo mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${SCRIPT_DIR}"

# 5. Summary
echo "[5/5] Build Complete!"
echo "================================================================"
ls -lh "${OUT_DIR}"/*.iso
echo ""
echo "Test in QEMU/KVM or flash to USB with Ventoy / BalenaEtcher."
echo "================================================================"
