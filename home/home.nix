{ pkgs, ... }:
{
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      monitor = ",preferred,auto,1";
      "$mod" = "SUPER";
      "$term" = "kitty";

      bind = [
        "$mod, RETURN, exec, $term"
        "$mod, Q, killactive"
        "$mod, SPACE, exec, wofi --show drun"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod SHIFT, E, exit"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"

        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];

      exec-once = [
        "waybar"
        "hyprpaper"
        "mako"
        "hypridle"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
    };
  };
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



  programs.firefox = {
    enable = true;
    policies.ExtensionSettings = {
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/vimium-ff/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  };

  programs.fish.enable = true;
  programs.git.enable = true;
  programs.starship.enable = true;

  home.packages = with pkgs; [ ];
}
