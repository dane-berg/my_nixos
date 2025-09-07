{
  pkgs,
  username,
  ...
}: {
  # You can test whether variables like inputs, username, etc. are actually reaching your module by adding debug lines like:
  # trace "inputs is: ${builtins.toString (builtins.attrNames inputs)}" true

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

  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  # TODO: setup secrets & user passwords, and then enable the setting below
  # Don't allow mutation of users outside the config.
  # users.mutableUsers = false;
  users.users."${username}" = {
    home = "/home/${username}";
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      #  thunderbird, etc
    ];
  };
}
