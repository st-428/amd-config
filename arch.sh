#!/bin/bash
set -e 

echo "--- 1. 更新系統並安裝軟體包 ---"
DRIVERS="mesa vulkan-radeon libva-mesa-driver rocm-hip-sdk intel-ucode"
TOOLS="wget curl git p7zip unrar unzip zip python nodejs npm base-devel"
SYSTEM="gparted openssh neovim htop nvtop fastfetch fish mpv pandoc blender rclone"
FONTS="ttf-jetbrains-mono-nerd noto-fonts-cjk fcitx5-im fcitx5-chewing"
DESKTOP="niri xwayland-satellite fuzzel alacritty xdg-desktop-portal wl-clipboard mpvpaper mako hyprlock nautilus gvfs libnautilus-extension polkit-kde-agent xorg-xhost nwg-look"
VIRT="ufw tailscale qemu-desktop libvirt dnsmasq libguestfs virt-manager docker docker-compose"

sudo pacman -Syu --needed --noconfirm $DRIVERS $TOOLS $SYSTEM $FONTS $DESKTOP $VIRT

echo "--- 2. 修改 faillock 設定 ---"
sudo sed -i 's/^#\?deny = .*/deny = 0/' /etc/security/faillock.conf

echo "--- 3. 設定環境變數 ---"
sudo bash -c 'cat > /etc/environment <<EOF
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
ELECTRON_OZONE_PLATFORM_HINT=auto
LIBVA_DRIVER_NAME=radeonsi
EOF'

echo "--- 4. 設定 mkinitcpio ---"
sudo sed -i 's/^MODULES=(.*/MODULES=(amdgpu i915)/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

echo "--- 5. 安裝 yay ---"
if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

echo "--- 6. 使用 yay 安裝其餘軟體 ---"
yay -S --noconfirm google-chrome tty-clock visual-studio-code-bin

echo "--- 7. 啟動所有服務 ---"
services=(libvirtd virtnetworkd virtstoraged tailscaled docker ufw)
for svc in "${services[@]}"; do
  sudo systemctl enable --now "$svc"
done

echo "--- 8. 設定虛擬化網路 ---"
sleep 2
sudo virsh net-start default 2>/dev/null || true
sudo virsh net-autostart default

echo "--- 9. 使用者權限設定 ---"
sudo usermod -aG libvirt,kvm,docker,render,video $USER

echo "--- 10. 網路與字體設定 ---"
sudo ufw enable --force
sudo tailscale up --ssh
fc-cache -fv

echo "--- 11. 從 GitHub 恢復 Dotfiles ---"
DOTFILES_REPO="https://github.com/st-428/amd-config.git"
TEMP_DOTFILES="/tmp/my_dotfiles"
git clone $DOTFILES_REPO $TEMP_DOTFILES
rsync -av $TEMP_DOTFILES/ $HOME/.config/
chown -R $USER:$USER $HOME/.config
rm -rf $TEMP_DOTFILES

echo "-------------------------------------------------------"
echo "✅ 所有設定完成！"
echo "🚀 建議執行：sudo reboot"
echo "-------------------------------------------------------"
