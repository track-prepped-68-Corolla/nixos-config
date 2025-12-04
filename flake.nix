{
  description = "nixos config";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      catppuccin.url = "github:catppuccin/nix";
      catppuccin.inputs.nixpkgs.follows = "nixpkgs";

      jovian-nixos.url = "github:jovian-experiments/jovian-nixos";

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };

outputs = { self, nixpkgs, catppuccin, home-manager, jovian-nixos, ... }@inputs:

{

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem{
        specialArgs = { inherit inputs catppuccin home-manager jovian-nixos; };

      modules = [
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        jovian-nixos.nixosModules.default
        {nix.settings.experimental-features = ["nix-command" "flakes"];}
      ];
    };

  };
  
}
