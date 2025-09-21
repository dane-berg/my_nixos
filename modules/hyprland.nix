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

    shellAliases = {
      activeMonitor = "hyprctl activeworkspace | head -n1 | cut -d' ' -f7 | tr -d ':'";
      activeMonitorId = "hyprctl activeworkspace | grep 'monitorID' | cut -d' ' -f2";
    };

    systemPackages = with pkgs; [
      (
        waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
        })
      )
      dunst
      swww
      kitty
      rofi
      networkmanagerapplet
      kdePackages.dolphin
      grim
      hyprshot
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

  services.udisks2.enable = true;
}
