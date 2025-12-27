{
  description = "NixOS Configuration";

  inputs = {
    # --- Core ---
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Hardware & System ---
    nixos-hardware.url = "github:track-prepped-68-Corolla/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    jovian-nixos.url = "github:jovian-experiments/jovian-nixos";

    # --- Desktop & Theming ---
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # --- Applications ---
    # [NEW] Added Nixvim input here
    nixvim = {
        url = "github:nix-community/nixvim";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # 1. SHARED ARGUMENTS
      # We pass 'inputs' to all modules so they can access things like inputs.nixvim
      sharedArgs = {
        inherit inputs;
        # We also inherit specific inputs for convenience if your modules expect them
        inherit (inputs) catppuccin home-manager jovian-nixos nixos-hardware;
      };

      # 2. SHARED MODULES
      # These modules are applied to every host defined below
      sharedModules = [
        # Core
        inputs.home-manager.nixosModules.default
        inputs.sops-nix.nixosModules.sops

        # Desktop / Theming
        inputs.catppuccin.nixosModules.catppuccin
        inputs.stylix.nixosModules.stylix
        inputs.nixos-cosmic.nixosModules.default
        inputs.jovian-nixos.nixosModules.default

        # Inline Configuration (Caches, Plasma, Nix settings)
        {
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            substituters = [ "https://cosmic.cachix.org/" ];
            trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
          };

          # Register Plasma Manager for Home Manager usage
          home-manager.sharedModules = [
            inputs.plasma-manager.homeModules.plasma-manager
          ];
        }
      ];
    in
    {
      nixosConfigurations = {

        # --- Host: ROG ---
        rog = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/rog
            inputs.nixos-hardware.nixosModules.asus-flow-gz301vu
          ];
        };

        # --- Host: Thinkpad ---
        thinkpad = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/thinkpad
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
          ];
        };

        # --- Host: Talos ---
        talos = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/talos
          ];
        };

        # --- Host: Strix ---
        strix = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/strix
          ];
        };

      };
    };
}
