{ pkgs, ... }:
let
  vimium = {
    name = "{d7742d87-e61d-4b78-b8a1-b469842139fa}"; # vimium-ff guid
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/vimium-ff/latest.xpi";
      installation_mode = "force_installed";
    };
  };
in
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
    neovim
	firefox
	git
  ];
  programs.fish = {
	shellAliases = {
			#everyday apps
			n = "nvim";
			f = "firefox";
			# git
			gs = "git status";
			ga = "git add -A";
			gc = "git commit";
			gp = "git push";


		};

	};


  programs.fish.enable = true;

  programs.firefox = {
    enable = true;
    policies.ExtensionSettings = {
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/vimium-ff/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  };
  # Force-install Vimium into zen-browser on first launch.
 
}
