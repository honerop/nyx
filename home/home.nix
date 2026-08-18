{ pkgs,inputs, ... }:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  programs.nixvim = {
  enable = true;
  clipboard = {
    register = "unnamedplus";
    providers.wl-copy.enable = true;
  };
  opts = {
  	number =true;
	relativenumber = true;
	};
  plugins = {
    lualine.enable = true;
    telescope.enable = true;
    nvim-tree.enable = true;
    treesitter = {
      enable = true;
      settings.ensure_installed = [ "nix" "lua" "bash" "python" ];
    };
    lsp = {
      enable = true;
      servers = {
        nil_ls.enable = true;   # nix LSP
        pyright.enable = true;
      };
    };
    cmp.enable = true;          # autocompletion
  };
};

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      monitor = ",preferred,auto,1";
      "$mod" = "SUPER";
      "$term" = "ghostty";

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
	"$mod, h, movefocus, l"
	"$mod, l, movefocus, r"
	"$mod, k, movefocus, u"
	"$mod, j, movefocus, d"
	"$mod SHIFT, h,  resizeactive, -50 0"
	"$mod SHIFT, l, resizeactive, 50 0"
	"$mod SHIFT, k,    resizeactive, 0 -50"
	"$mod SHIFT, j,  resizeactive, 0 50"


        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];

      exec-once = [
        "waybar"
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
    height = 32;
    modules-center = [ "clock" ];

    clock = {
      format = "{:%H:%M}";
      format-alt = "{:%A, %d %B %Y}";
      tooltip-format = "{:%Y-%m-%d}";
    };
  };

  style = ''
    * {
      font-family: monospace;
      font-size: 14px;
    }

    window#waybar {
      background: #000000;
      color: #ffffff;
    }

    #clock {
      padding: 0 12px;
      color: #ffffff;
    }
  '';
};

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
    };
  };
	programs.fish = {
	shellInit = ''
		set -gx SUDO_EDITOR nvim
	'';
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
    "addon@darkreader.org" = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/darkreader/latest.xpi";
      installation_mode = "force_installed";
    };
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "force_installed";
    };
  };
};

  services.hyprpaper = {
    enable = true;
  };
xdg.configFile."hypr/hyprpaper.conf".text = ''
  preload = ${../assets/wallpaper.png}

  wallpaper {
      monitor = 
      path = ${../assets/wallpaper.png}
      fit_mode = cover
  }
'';

	programs.fish.enable = true;

  programs.git.enable = true;
  programs.starship.enable = true;
programs.ghostty = {
  enable = true;
  settings = {
    keybind = [
      "alt+v=activate_key_table:vim"
      "vim/"
      "vim/j=scroll_page_lines:1"
      "vim/k=scroll_page_lines:-1"
      "vim/ctrl+d=scroll_page_down"
      "vim/ctrl+u=scroll_page_up"
      "vim/ctrl+f=scroll_page_down"
      "vim/ctrl+b=scroll_page_up"
      "vim/shift+j=scroll_page_down"
      "vim/shift+k=scroll_page_up"
      "vim/g>g=scroll_to_top"
      "vim/shift+g=scroll_to_bottom"
      "vim/slash=start_search"
      "vim/n=navigate_search:next"
      "vim/v=copy_to_clipboard"
      "vim/y=copy_to_clipboard"
      "vim/shift+semicolon=toggle_command_palette"
      "vim/escape=deactivate_key_table"
      "vim/q=deactivate_key_table"
      "vim/i=deactivate_key_table"
      "vim/catch_all=ignore"
    ];
  };
};
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;  # caching, much faster than plain direnv+nix
    enableBashIntegration = true;  # or enableZshIntegration, enableFishIntegration

};
gtk = {
  enable = true;
  theme = {
    name = "Adwaita-dark";
    package = pkgs.gnome-themes-extra;
  };
  iconTheme = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };
};
home.pointerCursor = {
  gtk.enable = true;
  x11.enable = true;
  package = pkgs.bibata-cursors;
  name = "Bibata-Modern-Ice";
  size = 24;
};
dconf.settings."org/gnome/desktop/interface" = {
  	color-scheme = "prefer-dark";
  	gtk-theme = "Adwaita-dark";
	};


  home.packages = with pkgs; [ ];
}


  
