{pkgs, ...}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.shellAliases = {
    nixrb = "/etc/nixos/rebuild-nixos.sh";
    nixup = "/etc/nixos/update-nixos.sh";
  };

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
