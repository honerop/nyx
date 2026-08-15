{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # for Steam/Wine compatibility
  };

  hardware.nvidia = {
    modesetting.enable = true;        # required for Wayland
    powerManagement.enable = true;    # helps with suspend/resume
    powerManagement.finegrained = false;
    open = true;                      # open-source kernel modules (Turing+); false for older cards
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Wayland/Hyprland needs these env vars for NVIDIA
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1"; # electron apps on wayland
  };

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
}
