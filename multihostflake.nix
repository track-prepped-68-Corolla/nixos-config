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
      # Define shared specialArgs to keep the config clean
      sharedArgs = { inherit inputs catppuccin home-manager jovian-nixos nixos-hardware; };
      
      # Define shared modules that apply to both hosts
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
        
        # Configuration for host1
        host1 = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/host1 # Path to host1 specific config
            nixos-hardware.nixosModules.asus-flow-gz301vu
          ];
        };

        # Configuration for host2
        host2 = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/host2 # Path to host2 specific config
            # Add any host2-specific hardware modules here
          ];
        };
        
      };
    };
}