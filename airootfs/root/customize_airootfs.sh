#!/usr/bin/env bash
# ==============================================================================
# ApexOS — airootfs customization script (runs inside chroot during build)
# ==============================================================================
set -e -u

# 1. Locale & Timezone defaults
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# 2. Create live user 'apex' with gaming/audio/video/sudo groups
if ! id -u apex >/dev/null 2>&1; then
  for grp in wheel video audio input storage optical network gamemode; do
    groupadd -f "$grp"
  done
  useradd -m -G wheel,video,audio,input,storage,optical,network,gamemode -s /bin/bash apex
  echo "apex:apex" | chpasswd
  echo "root:apex" | chpasswd
fi

# Passwordless sudo for wheel in live session
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/10-apexos-live
chmod 440 /etc/sudoers.d/10-apexos-live

# 3. Enable core desktop, gaming, scheduler, and NVIDIA power services
systemctl enable sddm.service || true
systemctl enable NetworkManager.service || true
systemctl enable bluetooth.service || true
systemctl enable power-profiles-daemon.service || true
systemctl enable ananicy-cpp.service || true
systemctl enable irqbalance.service || true
systemctl enable fstrim.timer || true
systemctl enable cups.service || true
systemctl enable cronie.service || true
systemctl enable ufw.service || true

# Enable sched-ext loader if present
systemctl enable scx_loader.service || true

# Enable NVIDIA Dynamic Boost (laptop GPU wattage boost) & suspend/hibernate VRAM preservation
systemctl enable nvidia-powerd.service || true
systemctl enable nvidia-suspend.service || true
systemctl enable nvidia-hibernate.service || true
systemctl enable nvidia-resume.service || true

# Skip waiting for network during boot (shaves 2-5 seconds off boot time)
systemctl disable NetworkManager-wait-online.service || true
systemctl mask NetworkManager-wait-online.service || true

# 4. Set ApexOS Dark as the default KDE Plasma 6 Global Theme, Plasma style & splash
mkdir -p /etc/skel/.config
cat > /etc/skel/.config/kdeglobals <<'EOF'
[General]
ColorScheme=ApexOSDark
Name=ApexOS Dark

[Icons]
Theme=breeze-dark

[KDE]
LookAndFeelPackage=org.apexos.dark
SingleClick=false
widgetStyle=Breeze
EOF

cat > /etc/skel/.config/plasmarc <<'EOF'
[Theme]
name=ApexOSDark
EOF

cat > /etc/skel/.config/ksplashrc <<'EOF'
[KSplash]
Engine=KSplashQML
Theme=org.apexos.dark
EOF

# Sync skel updates to live user
cp -af /etc/skel/. /home/apex/ || true
chown -R apex:apex /home/apex

# Remove one-shot build hook so it never re-runs after ISO creation
rm -f /etc/pacman.d/hooks/99-apexos-customize.hook
