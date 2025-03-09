{
  inputs,
  pkgs,
  system,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Enable systemwide dark mode with stylix
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

  environment.shellAliases = {
    subl = "sublime";
  };

  programs.firefox.enable = false;

  environment.systemPackages = with pkgs; [
    discord
    libreoffice
    obsidian
    # TODO: setup syntax highlighting using https://gist.github.com/wmertens/9f0f1db0e91bc5e3e430
    sublime
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs system;};
    backupFileExtension = "hm-backup";
    users.daneb = import ./home.nix;
  };
}
