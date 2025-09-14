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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

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
    extraConfig = {
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
