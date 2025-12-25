{
  description = "nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

    impermanence.url = "github:nix-community/impermanence";


    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    jovian-nixos.url = "github:jovian-experiments/jovian-nixos";

    nixos-hardware.url = "github:track-prepped-68-Corolla/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, catppuccin, stylix, home-manager, plasma-manager, sops-nix, impermanence, nixos-cosmic, jovian-nixos, nixos-hardware, ... }@inputs:
    let
      sharedArgs = { inherit inputs catppuccin home-manager jovian-nixos nixos-hardware; };
      
      sharedModules = [
        #inputs.plasma-manager.homeModules.plasma-manager
        catppuccin.nixosModules.catppuccin
        {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default
        home-manager.nixosModules.home-manager
         {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
          }
        inputs.home-manager.nixosModules.default
        stylix.nixosModules.stylix
        jovian-nixos.nixosModules.default
        sops-nix.nixosModules.sops
        { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
      ];
    in
    {
      nixosConfigurations = {
        
        # Changed back to ROG
        rog = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/rog
            nixos-hardware.nixosModules.asus-flow-gz301vu
          ];
        };

        # Second host
        thinkpad = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/thinkpad
            nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
          ];
        };

        # third host
        talos = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/talos

          ];
        };
        
      };
    };
}
