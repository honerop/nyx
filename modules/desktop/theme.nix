{ pkgs, ... }:
{
  # Swap this out for a proper Catppuccin/Tokyo Night module later —
  # this just gets a coherent dark look out of the box.
  environment.systemPackages = with pkgs; [
    catppuccin-gtk
    papirus-icon-theme
  ];

  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

  environment.sessionVariables = {
    GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
  };
}
