# ApexOS — Gaming Linux Distribution

**ApexOS** (by **mydesktop.club**) is an Arch Linux distribution built on an **x86-64-v3** optimized performance stack, tuned specifically for **NVIDIA GPUs**, **KDE Plasma 6 (Wayland)**, and out-of-the-box **Steam + Proton** Windows gaming.

---

## What’s Included Out of the Box

### Performance & Gaming Engine
- **Kernel:** BORE low-latency gaming kernel + `sched_ext`
- **CPU Scheduler:** `scx-scheds` (`scx_lavd` gaming scheduler enabled automatically) + `ananicy-cpp` with automated game priority rules
- **NVIDIA Stack:** NVIDIA Open Kernel Modules, `nvidia-utils`, `lib32-nvidia-utils`, `nvidia-settings`, `libva-nvidia-driver`, Wayland DRM KMS (`modeset=1`, `fbdev=1`), 10 GB shader cache, VRAM suspend preservation, and Resizable BAR
- **Windows Gaming / Proton:**
  - `steam`, Proton runtime stack, `protonup-qt`, `gamescope`, `gamemode`, `mangohud`, `goverlay`, `lutris`, `winetricks`
  - Kernel tweaks: **NTSYNC** enabled at boot, `vm.max_map_count=2147483642`, `kernel.split_lock_mitigate=0`, `1048576` file descriptors for Esync/Fsync, **ZRAM (`zstd`)**, and **BBR + CAKE** networking
  - Built-in Steam wrapper: set any Steam game’s Launch Options to:
    ```bash
    apexos-game-launch %command%
    ```

### Desktop, Installer & Preinstalled Software
- **Graphical Installer:** Full **Calamares** installer (**Install ApexOS** right on the live desktop) with custom obsidian-glass branding, 4-slide presentation, Btrfs `zstd:1` / ext4 / xfs partitioning, and automatic NVIDIA initramfs + `systemd-boot` setup
- **Desktop Environment:** KDE Plasma 6 (Wayland) + SDDM + Glass Squircle **ApexOS** Plymouth boot splash & Obsidian Glass default wallpaper
- **Software Suite:**
  - **Brave Browser** (`brave-bin`)
  - **Shelly Package Manager** (`shelly`)
  - **Krita**
  - **VLC Media Player**
  - **ProtonVPN** (`proton-vpn-gtk-app`)
  - **LibreOffice Fresh**
  - **MyDesktop Club Web App** (`https://mydesktop.club` standalone desktop app & menu entry)

---

## Option 1: Build the Bootable ISO Locally (On Arch Linux)

1. Install `archiso` on your Linux machine:
   ```bash
   sudo pacman -S archiso base-devel git curl
   ```
2. Open a terminal inside the `apexos` folder and run:
   ```bash
   chmod +x build-iso.sh
   ./build-iso.sh
   ```
3. Your bootable ISO will be generated in `out/ApexOS-YYYY.MM.DD-x86_64.iso`.

---

## Option 2: Build Automatically on GitHub’s Free Servers (GitHub Actions)

1. Push or upload the contents of this `apexos` folder to the root of a **Public** GitHub repository (so `.github/workflows/build-iso.yml` sits at the root).
2. Open the **Actions** tab → select **Build ApexOS ISO** → click **Run workflow**.
3. Download your finished `ApexOS` ISO (or `.part*` files + `rejoin-iso.sh` / `rejoin-iso.bat`) straight from the **Releases** tab.

## Live Session Credentials
- **Username:** `apex` (auto-logs into KDE Plasma Wayland)
- **Password:** `apex` (passwordless `sudo` enabled in live session)
- **Installer:** Double-click **Install ApexOS** on the desktop to launch the branded Calamares graphical installer!
