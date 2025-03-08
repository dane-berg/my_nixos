{pkgs, ...}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  programs.firefox.enable = false;

  environment.shellAliases = {
    gch = "git checkout";
    gd = "git diff";
    gdc = "git diff --cached";
    gdh = "git diff HEAD";
    gl = "git log";
    glp = "git log -p";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gst = "git status";
    # gsw = "git checkout master-stable && git pull && git checkout";
    # rbm = "git fetch origin master && git rebase origin/master";
    nixrb = "/etc/nixos/rebuild-nixos.sh";
    nixup = "/etc/nixos/update-nixos.sh";
    subl = "sublime";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alejandra
    home-manager
    libnotify
    neofetch
  ];
}
