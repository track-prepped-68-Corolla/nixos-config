{
  description = "nixos config";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      catppuccin.url = "github:catppuccin/nix";
      # 🌟 Add this line to ensure compatibility
      catppuccin.inputs.nixpkgs.follows = "nixpkgs";

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };

outputs = { self, nixpkgs, catppuccin, home-manager, ... }@inputs:

{

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem{
        specialArgs = { inherit inputs catppuccin home-manager; };

      modules = [
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        {nix.settings.experimental-features = ["nix-command" "flakes"];}
      ];
    };

  };
  
}
