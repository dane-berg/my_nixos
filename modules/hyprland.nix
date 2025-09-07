{
  inputs,
  pkgs,
  system,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages."${system}".hyprland;
  };

  environment = {
    sessionVariables = {
      # If your cursor becomes invisible
      WLR_NO_HARDWARE_CURSORS = "1";
      # Hint electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = [
      (
        pkgs.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
        })
      )
      pkgs.dunst
      pkgs.swww
      pkgs.kitty
      pkgs.rofi-wayland
      pkgs.networkmanagerapplet
      pkgs.kdePackages.dolphin
    ];
  };

  hardware = {
    graphics.enable = true;
    # Most wayland compositors need this
    nvidia.modesetting.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
