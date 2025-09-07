{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-snapd = {
      url = "github:io12/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      erebus = let
        username = "daneb";
        system = "x86_64-linux";
        specialArgs = {inherit inputs username system;};
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            ./hosts/erebus/configuration.nix
            home-manager.nixosModules.home-manager
            {
              # TODO: move overlays out of home-manager and turn on these settings
              # home-manager.useGlobalPkgs = true;
              # home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./users/${username}/home.nix;
              home-manager.backupFileExtension = "hm-backup";
            }
            inputs.stylix.nixosModules.stylix
            inputs.nix-snapd.nixosModules.default
          ];
        };

      castor = let
        username = "daneb";
        system = "x86_64-linux";
        specialArgs = {inherit inputs username system;};
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            ./hosts/castor/configuration.nix
            home-manager.nixosModules.home-manager
            {
              # TODO: move overlays out of home-manager and turn on these settings
              # home-manager.useGlobalPkgs = true;
              # home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./users/${username}/home.nix;
              home-manager.backupFileExtension = "hm-backup";
            }
            inputs.stylix.nixosModules.stylix
            inputs.nix-snapd.nixosModules.default
          ];
        };
    };
  };
}
