{pkgs, ...}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.shellAliases = {
    nixrb = "/etc/nixos/rebuild-nixos.sh";
    nixup = "/etc/nixos/update-nixos.sh";
  };

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alejandra
    git
    home-manager
    libnotify
    neofetch
  ];
}
