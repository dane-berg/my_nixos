{
  inputs,
  config,
  pkgs,
  system,
  ...
}: {
  nixpkgs = {
    overlays = [
      inputs.nur.overlay
    ];
    config.allowUnfree = true;
  };

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
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "librewolf.desktop"
        "discord.desktop"
        "obsidian.desktop"
        "codium.desktop"
        "org.gnome.Console.desktop"
      ];
    };
  };

  programs.git = {
    enable = true;
    extraConfig = {
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
      };
      search = {
        force = true;
        default = "DuckDuckGo";
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
            urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@nw"];
          };
          "Bing".metaData.alias = "@b"; # builtin engines only support specifying one additional alias
          "Wikipedia (en)".metaData.alias = "@w";
        };
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
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
    userSettings = {
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
