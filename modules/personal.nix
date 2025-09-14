{
  inputs,
  pkgs,
  system,
  ...
}: {
  # Enable systemwide dark mode with stylix
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  };

  environment.shellAliases = {
    subl = "sublime";
  };

  programs.firefox.enable = false; # disable because we install librewolf (in home.nix)

  environment.systemPackages = with pkgs; [
    google-chrome
    discord
    vesktop # modified discord with actually-functional screen sharing
    gimp-with-plugins
    libreoffice
    obsidian
    # TODO: setup syntax highlighting using https://gist.github.com/wmertens/9f0f1db0e91bc5e3e430
    sublime
  ];
}
