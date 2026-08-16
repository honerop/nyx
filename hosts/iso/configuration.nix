{ config, pkgs, lib, modulesPath, inputs, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/core/base.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/apps.nix
    ../../modules/desktop/theme.nix
  ];

  image.baseName = lib.mkForce "nyx";
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  system.nixos.distroName = "Nyx";

  system.nixos.distroId = "nyx";
isoImage.grubTheme = pkgs.callPackage ../../branding/grub-theme { };


  # We don't use ZFS at all; silence the boot.zfs.forceImportRoot default warning
  # by opting in to the new (safer) default explicitly.
  boot.zfs.forceImportRoot = false;

  networking.hostName = "nyx-live";

  # True auto-login: greetd's `initial_session` launches Hyprland directly for
  # `live` on first boot, skipping the tuigreet prompt entirely. (The earlier
  # `services.getty.autologinUser` setting only affects plain tty logins, not
  # greetd — it did nothing useful here and has been removed.) If this session
  # ever exits, greetd falls back to the normal tuigreet prompt below.
  services.greetd.settings.initial_session = {
    command = "${pkgs.hyprland}/bin/Hyprland";
    user = "live";
  };

  users.users.live = {
    isNormalUser = true;
    initialPassword = "nyx";
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Ship a copy of this flake's actual source files on the ISO so the
  # installer can copy them to the target disk and build from them.
  # Filtered (not a raw `../..`) so build artifacts sitting next to the
  # flake — the `result` symlink, `.qcow2` test disks, `.git`, etc. — never
  # get embedded. Without this, anything you happen to leave in the project
  # directory when you run `nix build` gets copied onto the ISO too.
  environment.etc."nyx-src".source = builtins.path {
    path = ../..;
    name = "nyx-src";
    filter = path: type:
      let base = baseNameOf path; in
      !(builtins.elem base [ "result" ".git" ".direnv" ".gitignore" ])
      && !(lib.hasSuffix ".qcow2" base)
      && !(lib.hasSuffix ".iso" base)
      && !(lib.hasSuffix ".img" base);
  };

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "nyx-install" (builtins.readFile ../../install.sh))
	inputs.disko.packages.${pkgs.system}.disko
    git
    curl
    vim
  ];

  home-manager.users.live = import ../../home/home.nix;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  system.stateVersion = "25.05";
}
