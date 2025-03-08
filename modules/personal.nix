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

  environment.systemPackages = with pkgs; [
    discord
    libreoffice
    obsidian
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs system;};
    backupFileExtension = "hm-backup";
    users.daneb = import ./home.nix;
  };
}
