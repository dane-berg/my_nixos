{
  inputs,
  config,
  pkgs,
  system,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    # wallpaper
    # swww init &
    # swww img <filepath> &

    nm-applet --indicator &

    waybar &

    dunst
  '';
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "daneb";
  home.homeDirectory = "/home/daneb";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # https://www.bekk.christmas/post/2021/16/dotfiles-with-nix-and-home-manager is a helpful guide
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/daneb/etc/profile.d/hm-session-vars.sh
  #

  # Use `dconf watch /` to track stateful changes you are doing, then set them here.
  # I only enable dconf on gnome
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "librewolf.desktop"
          "discord.desktop"
          "obsidian.desktop"
          "codium.desktop"
          "org.gnome.Console.desktop"
        ];
      };
      "org/gnome/desktop/session" = {
        idle-delay = 0;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      pull.rebase = true;
      user.name = "dane-berg";
      user.email = "dayneberg12@gmail.com";
    };
  };

  # a useful reference at https://www.reddit.com/r/NixOS/comments/15zkfj1/simple_homemanager_firefox_setup/
  programs.librewolf = {
    enable = true;
    settings = {
      "privacy.clearOnShutdown.history" = false;
      "webgl.disabled" = false;
    };
    profiles.default = {
      isDefault = true;
      settings = {
        "browser.startup.page" = 3; # Resume the previous browser session
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      };
      search = {
        force = true;
        default = "ddg"; # DuckDuckGo
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "NixOS Wiki" = {
            urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
            icon = "https://nixos.wiki/favicon.png";
            updateInterval = 2 * 24 * 60 * 60 * 1000; # every 2 days
            definedAliases = ["@nw"];
          };
          "bing".metaData.alias = "@b"; # builtin engines only support specifying one additional alias
          "wikipedia".metaData.alias = "@w";
        };
      };
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        # explore using; nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
        darkreader
        onepassword-password-manager
        react-devtools
        ublock-origin
      ];
      # attempt to auto-enable extensions
      extraConfig = ''
        user_pref("extensions.autoDisableScopes", 0);
        user_pref("extensions.enabledScopes", 15);
      '';
    };
  };

  # a useful reference at https://github.com/thomashoneyman/.dotfiles/blob/69d61ae8650f12f123d375534714c78a3095fb0e/modules/programs/default.nix
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.userSettings = {
      "editor.formatOnSave" = true;
      "prettier.singleAttributePerLine" = true;
      "workbench.colorTheme" = "Stylix";
      "explorer.confirmDragAndDrop" = false;
      "typescript.updateImportsOnFileMove.enabled" = "always";

      "[css]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[html]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[json]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[nix]" = {
        "editor.defaultFormatter" = "kamadorueda.alejandra";
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "alejandra.program" = "alejandra";
    };
    profiles.default.extensions = with inputs.nix-vscode-extensions.extensions."${system}".open-vsx; [
      # explore extensions using
      # nix repl
      # :lf github:nix-community/nix-vscode-extensions/9edbf5d1c9c9b5c5dd1fa6d6fc0c3cd01ec09346
      esbenp.prettier-vscode
      dsznajder.es7-react-js-snippets
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
      # example plugin definition
      # inputs.hyprland-plugins.packages."${system}".borders-plus-plus
    ];
    settings = {
      general.layout = "dwindle";
      # monitors
      # TODO: make this host-specific before moving erebus to hyprland
      monitor = [
        ",preferred,auto,auto"
        "DP-3, 2560x1440, 0x0, 1"
        "DP-2, 2560x1440, 2560x0, 1"
      ];
      # keybinds
      bind = [
        # see https://wiki.hypr.land/Configuring/Binds/
        # use wev to discover the name of various keys
        # applications
        "SUPER, S, exec, rofi -show drun -show-icons"
        "SUPER, Q, exec, kitty" # TODO: set kitty as $terminal
        "SUPER, E, exec, dolphin"
        "SUPER, R, exec, $menu"
        # windows
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"
        "SUPER, C, killactive"
        "SUPER, M, exit"
        "SUPER, V, togglefloating"
        "SUPER, X, movewindow, mon:+1" # move current window to the next monitor
        # dwindle
        "SUPER, P, pseudo,"
        "SUPER, J, togglesplit, "
        "SUPER, Z, swapsplit, "
        # screen capture
        "SUPER, grave, exec, hyprshot -m output -m active -o ~/Pictures" # captures the current monitor
        "SUPER, 1, exec, hyprshot -m window -m active -o ~/Pictures" # captures the current window
        "SUPER, 2, exec, hyprshot -m region -o ~/Pictures" # captures a region you select
        # audio
        "SUPER, equal, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        "SUPER, minus, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
      # startup script
      exec-once = ''${startupScript}/bin/start'';
      dwindle = {
        preserve_split = true; # enables togglesplit
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        height = 20;
        layer = "top";
        modules-left = ["custom/launcher" "cpu" "memory" "hyprland/workspaces"];
        modules-center = ["mpris"];
        modules-right = ["network" "pulseaudio" "battery" "tray" "idle_inhibitor" "clock"];

        "custom/launcher" = {
          format = "󱄅";
          on-click = "rofi -show drun -show-icons";
        };

        "cpu" = {
          interval = 10;
          format = "CPU {}%";
          max-length = 10;
        };

        "memory" = {
          interval = 30;
          format = "Memory {}%";
          format-alt = "Memory {used:0.1f}GB";
          max-length = 12;
        };

        "hyprland/workspaces" = {
          format = "{name}";
          all-outputs = true;
          on-click = "activate";
          format-icons = {
            active = "󱎴";
            default = "󰍹";
          };
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
            "6" = [];
            "7" = [];
            "8" = [];
            "9" = [];
          };
        };

        "mpris" = {
          format = "{player_icon} {title}";
          format-paused = " {status_icon} <i>{title}</i>";
          max-length = 80;
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = {
            paused = "⏸";
          };
        };

        "network" = {
          format-wifi = "<small>{bandwidthDownBytes}</small> {icon}";
          min-length = 10;
          fixed-width = 10;
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format = "{essid}";
          interval = 1;
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        };

        "pulseaudio" = {
          format = "{icon}";
          format-muted = "󰖁";
          format-icons = {
            default = ["" "" "󰕾"];
          };
          on-click = "pamixer -t";
          on-scroll-up = "pamixer -i 1";
          on-scroll-down = "pamixer -d 1";
          on-click-right = "exec pavucontrol";
          tooltip-format = "Volume {volume}%";
        };

        "battery" = {
          bat = "BAT0";
          adapter = "ADP0";
          interval = 60;
          states = {
            warning = 15;
            critical = 7;
          };
          max-length = 20;
          format = "{icon}";
          format-warning = "{icon}";
          format-critical = "{icon}";
          format-charging = "<span font-family='Font Awesome 6 Free'></span>";
          format-plugged = "󰚥";
          format-notcharging = "󰚥";
          format-full = "󰂄";
          format-alt = "<small>{capacity}%</small>";
          format-alt-warning = "<small>{capacity}%</small>";
          format-critical-alt = "<small>{capacity}%</small>";
          format-icons = ["󱊡" "󱊢" "󱊣"];
        };

        "tray" = {
          spacing = 10;
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = " ";
            deactivated = " ";
          };
        };

        "clock" = {
          format = "{:%H:%M}";
          format-alt = "{:%b %d %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };

    style =
      /*
      css
      */
      ''

        * {
          font-family: JetBrains Mono, JetBrainsMono Nerd Font, Material Design Icons;
          font-size: 17px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(26, 27, 38, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
        }

        /* General styling for individual modules */
        #clock,
        #temperature,
        #mpris,
        #cpu,
        #memory,
        #tray,
        #workspaces,
        #custom-launcher,
        #custom-weather,
        #custom-wg {
          background-color: #222034;
          font-size: 14px;
          color: #8a909e;
          padding: 3px 8px;
          border-radius: 8px;
          margin: 8px 2px;
        }

        /* Styling for Network, Pulseaudio, Backlight, and Battery group */
        #network,
        #pulseaudio,
        #backlight,
        #battery {
          background-color: #222034;
          font-size: 20px;
          padding: 3px 8px;
          margin: 8px 0px;
        }

        /* Module-specific colors for Network, Pulseaudio, Backlight, Battery */
        #network, #pulseaudio { color: #5796E0; }
        #backlight { color: #ecd3a0; }
        #battery {
        color: #8fbcbb;
        padding-right: 14px
        }

        /* Battery state-specific colors */
        #battery.warning { color: #ecd3a0; }
        #battery.critical:not(.charging) { color: #fb958b; }

        /* Pulseaudio mute state */
        #pulseaudio.muted { color: #fb958b; }

        /* Styling for Language, Custom Wallpaper, Idle Inhibitor, Custom Refresh Rate group */
        #language,
        #custom-refresh-rate,
        #custom-wallpaper,
        #idle_inhibitor {
          background-color: #222034;
          color: #8a909e;
          padding: 3px 4px;
          margin: 8px 0px;
        }

        /* Rounded corners for specific group elements */
        #language { border-radius: 8px 0 0 8px; }
        #custom-refresh-rate { border-radius: 0 8px 8px 0; }
        #network { border-radius: 8px 0 0 8px; }
        #battery { border-radius: 0 8px 8px 0; }

        /* Temperature, CPU, and Memory colors */
        #temperature { color: #5796E0; }
        #cpu { color: #fb958b; }
        #memory { color: #a1c999; }

        /* Workspaces active button styling */
        #workspaces button {
          color: #5796E0;
          border-radius: 8px;
          box-shadow: inset 0 -3px transparent;
          padding: 3px 4px;
          transition: all 0.5s cubic-bezier(0.55, -0.68, 0.48, 1.68);
        }
        #workspaces button.active {
          color: #ecd3a0;
          font-weight: bold;
          border-radius: 8px;
          transition: all 0.5s cubic-bezier(0.55, -0.68, 0.48, 1.68);
        }

        #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
          border-radius: 8px;
        }

        /* Custom launcher */
        #custom-launcher {
          color: #5796E0;
          font-size: 22px;
          padding-right: 14px;
        }

        /* Tooltip styling */
        tooltip {
          border-radius: 15px;
          padding: 15px;
          background-color: #222034;
        }
        tooltip label {
          padding: 5px;
          font-size: 14px;
          }

      '';
  };

  home.packages = with pkgs; [
    pamixer
    pavucontrol # volume control
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
