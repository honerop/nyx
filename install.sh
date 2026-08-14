#!/usr/bin/env bash
# Nyx installer — run from the live ISO as: nyx-install
set -euo pipefail

echo "=== Nyx Installer ==="
echo "This will ERASE the target disk and install Nyx."
echo
lsblk
echo

read -rp "Target disk (e.g. /dev/sda, /dev/nvme0n1): " DISK
read -rp "This will DESTROY all data on ${DISK}. Type 'yes' to continue: " CONFIRM
[ "$CONFIRM" = "yes" ] || { echo "Aborted."; exit 1; }

BOOT_PART="${DISK}1"
ROOT_PART="${DISK}2"
if [[ "$DISK" == *nvme* || "$DISK" == *mmcblk* ]]; then
  BOOT_PART="${DISK}p1"
  ROOT_PART="${DISK}p2"
fi

echo "--> Partitioning ${DISK} (GPT: 512MiB ESP + rest as root)"
parted -s "$DISK" -- mklabel gpt
parted -s "$DISK" -- mkpart ESP fat32 1MiB 513MiB
parted -s "$DISK" -- set 1 esp on
parted -s "$DISK" -- mkpart primary 513MiB 100%

echo "--> Waiting for the kernel to pick up the new partition table"
partprobe "$DISK" || true
udevadm settle
for i in $(seq 1 20); do
  [ -b "$BOOT_PART" ] && [ -b "$ROOT_PART" ] && break
  sleep 0.5
done
if [ ! -b "$BOOT_PART" ] || [ ! -b "$ROOT_PART" ]; then
  echo "error: ${BOOT_PART} or ${ROOT_PART} never appeared — partitioning likely failed" >&2
  exit 1
fi

echo "--> Formatting"
mkfs.fat -F32 -n BOOT "$BOOT_PART"
mkfs.ext4 -F -L nixos "$ROOT_PART"
udevadm settle

echo "--> Mounting"
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot

echo "--> Setting up temporary swap on the target disk (helps low-RAM installs avoid OOM)"
SWAPFILE=/mnt/.install-swapfile
if [ ! -f "$SWAPFILE" ]; then
  fallocate -l 4G "$SWAPFILE" 2>/dev/null || dd if=/dev/zero of="$SWAPFILE" bs=1M count=4096
  chmod 600 "$SWAPFILE"
  mkswap "$SWAPFILE"
fi
swapon "$SWAPFILE"
trap 'swapoff "$SWAPFILE" 2>/dev/null; rm -f "$SWAPFILE"' EXIT

echo "--> Setting up /mnt/etc/nixos as a git repo"
DEFAULT_REMOTE="https://github.com/honerop/nyx"
read -rp "Git remote for your Nyx config [${DEFAULT_REMOTE}] (or 'none' to skip): " GIT_REMOTE
GIT_REMOTE="${GIT_REMOTE:-$DEFAULT_REMOTE}"

mkdir -p /mnt/etc/nixos
if [ "$GIT_REMOTE" != "none" ]; then
  echo "--> Cloning ${GIT_REMOTE}"
  git clone "$GIT_REMOTE" /mnt/etc/nixos
else
  echo "--> Skipping remote — copying embedded flake and git-initing it locally"
  cp -r /etc/nyx-src/. /mnt/etc/nixos/
  git -C /mnt/etc/nixos init -q
  git -C /mnt/etc/nixos config user.email "nyx@localhost"
  git -C /mnt/etc/nixos config user.name "Nyx Installer"
  cat > /mnt/etc/nixos/.gitignore <<'EOF'
result
*.qcow2
*.iso
*.img
EOF
  git -C /mnt/etc/nixos add -A
  git -C /mnt/etc/nixos commit -q -m "Initial import from ISO"
  echo "No remote was set. Push this later with, e.g.:"
  echo "  cd /etc/nixos && git remote add origin <your-repo-url> && git push -u origin main"
fi

echo "--> Generating hardware-configuration.nix"
nixos-generate-config --root /mnt --dir /mnt/etc/nixos/hosts/template

echo "--> Running nixos-install (this takes a while)"
# Cap build parallelism so peak memory use per build stays low — trades
# speed for headroom, which matters more on constrained VMs/hardware.
export NIX_CONFIG="cores = 1
max-jobs = 1"
nixos-install --root /mnt --flake /mnt/etc/nixos#nyx --no-root-passwd

echo
echo "=== Install complete! ==="
echo "Set your user's password before rebooting:"
echo "  nixos-enter --root /mnt -c 'passwd me'"
echo
echo "To update later: cd /etc/nixos && git pull && sudo nixos-rebuild switch --flake /etc/nixos#nyx"
echo "Then: reboot"
