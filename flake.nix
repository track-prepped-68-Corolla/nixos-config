{
  description = "nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    jovian-nixos.url = "github:jovian-experiments/jovian-nixos";

    nixos-hardware.url = "github:track-prepped-68-Corolla/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, catppuccin, home-manager, jovian-nixos, nixos-hardware, ... }@inputs:
    let
      sharedArgs = { inherit inputs catppuccin home-manager jovian-nixos nixos-hardware; };
      
      sharedModules = [
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        inputs.home-manager.nixosModules.default
        jovian-nixos.nixosModules.default
        { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
      ];
    in
    {
      nixosConfigurations = {
        
        # Changed back to ROG
        rog = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/ROG
            nixos-hardware.nixosModules.asus-flow-gz301vu
          ];
        };

        # Second host
        host2 = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/host2
          ];
        };
        
      };
    };
}
