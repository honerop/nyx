## WARNING! 
This project is in early development.

# Nyx

A NixOS-based Hyprland desktop distro with opinionated defaults, one bootable ISO,
and a declarative, reproducible installer via Nix flakes
## Layout

```
flake.nix                     entry point, defines two systems: `iso` and `nyx`
hosts/iso/configuration.nix   the live ISO (auto-login desktop + installer)
hosts/template/configuration.nix   what gets installed to disk
modules/core/base.nix         bootloader, nix settings, locale, base packages
modules/desktop/hyprland.nix  compositor, greeter, portals, audio
modules/desktop/apps.nix      waybar/wofi/mako/kitty/etc — the default app set
modules/desktop/theme.nix     GTK theme, icons, fonts
home/home.nix                 home-manager: keybinds, waybar layout, dotfiles
install.sh                    bundled on the ISO as `nyx-install`
```

## Build the ISO

On any machine with Nix + flakes enabled:

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage
# -> result/iso/nyx.iso
```

Write it to a USB stick:

```bash
sudo dd if=result/iso/nyx.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

## Install

1. Boot the USB. It auto-logs in as `live` (password `nyx`) straight into Hyprland.
2. Open a terminal (`Super+Return`) and run:
   ```bash
   sudo nyx-install
   ```
3. Follow the prompts (pick the target disk, confirm). It partitions, formats,
   copies this flake to `/mnt/etc/nixos`, generates hardware config, and runs
   `nixos-install --flake .#nyx`.
4. Set your user password and reboot as instructed at the end.

## Customizing

- Add/remove packages in `modules/desktop/apps.nix`.
- Change keybinds/waybar/dotfiles in `home/home.nix`.
- Swap the theme module for a real Catppuccin/Tokyo Night/Rose Pine module.
- Rename the `me` user and `nyx` hostname in `hosts/template/configuration.nix`.
- After the first real install, you'll likely want to split `hosts/template` into
  per-machine hosts (e.g. `hosts/laptop`, `hosts/desktop`) once hardware differs.

## Known simplifications (next steps)

- Partitioning in `install.sh` is manual/imperative (parted). Consider swapping in
  [disko](https://github.com/nix-community/disko) for a fully declarative,
  repeatable partition layout defined in Nix.
- No LUKS/full-disk-encryption yet — add it in `install.sh` + the template config
  if you want that.
- No Secure Boot (`lanzaboote`) — optional, adds complexity.
- GPU drivers (NVIDIA in particular) aren't configured — add
  `hardware.nvidia.*` / `services.xserver.videoDrivers` as needed once you know
  the target hardware.
