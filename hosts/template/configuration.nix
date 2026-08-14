{ config, pkgs, lib, modulesPath, inputs, ... }:
{
  imports = [
    ../../modules/core/base.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/apps.nix
    ../../modules/desktop/theme.nix
    # Generated at install time by `nixos-generate-config`. Not present
    # in the repo until install.sh creates it on the target machine.
    ./hardware-configuration.nix
  ];

  networking.hostName = "nyx";

  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
    # Set a real password after install: `passwd me`
    initialPassword = "changeme";
  };

  home-manager.users.me = import ../../home/home.nix;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  system.stateVersion = "25.05";
}
