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

echo "--> Writing temporary Disko config for ${DISK}"
DISKO_CFG=$(mktemp)
cat > "$DISKO_CFG" <<EOF
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "${DISK}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
EOF

echo "--> Running Disko (destroy + format + mount)"
# Erases the disk, creates partitions, formats them and mounts under /mnt
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount "$DISKO_CFG"

rm -f "$DISKO_CFG"

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
# --no-filesystems is important because Disko already defined the filesystems
nixos-generate-config --root /mnt --no-filesystems --dir /mnt/etc/nixos/hosts/template
git -C /mnt/etc/nixos add -A

echo
DEFAULT_USER="me"
read -rp "Username [${DEFAULT_USER}]: " USERNAME
USERNAME="${USERNAME:-$DEFAULT_USER}"
if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "error: '${USERNAME}' isn't a valid Linux username (lowercase letters/digits/-/_, can't start with a digit)" >&2
  exit 1
fi

TARGET_CONFIG="/mnt/etc/nixos/hosts/template/configuration.nix"
if [ "$USERNAME" != "$DEFAULT_USER" ] && [ -f "$TARGET_CONFIG" ]; then
  echo "--> Renaming default user '${DEFAULT_USER}' to '${USERNAME}' in ${TARGET_CONFIG}"
  sed -i \
    -e "s/users\.users\.${DEFAULT_USER}\b/users.users.${USERNAME}/g" \
    -e "s/home-manager\.users\.${DEFAULT_USER}\b/home-manager.users.${USERNAME}/g" \
    "$TARGET_CONFIG"
fi

echo "--> Running nixos-install (this takes a while)"
# Cap build parallelism so peak memory use per build stays low — trades
# speed for headroom, which matters more on constrained VMs/hardware.
export NIX_CONFIG="cores = 1
max-jobs = 1"
nixos-install --root /mnt --flake /mnt/etc/nixos#nyx --no-root-passwd

echo
echo "--> Set a password for the '${USERNAME}' user"
while true; do
  read -rsp "Password: " PASS1; echo
  read -rsp "Confirm password: " PASS2; echo
  if [ -z "$PASS1" ]; then
    echo "Password can't be empty — try again."
    continue
  fi
  if [ "$PASS1" != "$PASS2" ]; then
    echo "Passwords didn't match — try again."
    continue
  fi
  break
done
echo "${USERNAME}:${PASS1}" | nixos-enter --root /mnt -c 'chpasswd'
unset PASS1 PASS2

echo
echo "=== Install complete! ==="
echo
echo "To update later: cd /etc/nixos && git pull && sudo nixos-rebuild switch --flake /etc/nixos#nyx"
echo "Then: reboot"
