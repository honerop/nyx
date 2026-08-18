{ config, pkgs, lib, modulesPath, inputs, ... }:
{
imports = [
    ../../modules/core/base.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/apps.nix
    ../../modules/desktop/theme.nix
    ../../modules/hardware/bluetooth.nix
    ./hardware-configuration.nix
  ] ++ (if builtins.pathExists ./disko.local.nix
        then [ ./disko.local.nix ]
        else [ ./disko.nix ])
    ++ lib.optional (builtins.pathExists ./packages.local.nix) ./packages.local.nix;

  networking.hostName = "nyx";

  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
    # Set a real password after install: `passwd me`
    initialPassword = "changeme";
  };

  home-manager.users.me = import ../../home/home.nix;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
	programs.fish.enable = true;

  system.stateVersion = "25.05";
}
