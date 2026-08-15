{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # bar / launcher / notifications
    waybar
    wofi
    mako

    # terminal + shell
    kitty
    starship
    fish

    # wallpaper / lock / idle
    hyprpaper
    hyprlock
    hypridle

    # screenshots / clipboard / media keys
    grim
    slurp
    wl-clipboard
    playerctl
    brightnessctl

    # system tray bits
	wireplumber
    networkmanagerapplet

    # everyday apps
    firefox
    neovim
  ];

  programs.fish.enable = true;
}
