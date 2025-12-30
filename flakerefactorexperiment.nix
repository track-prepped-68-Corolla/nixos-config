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
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      # 1. SHARED ARGUMENTS
      # Makes 'inputs' available to all modules
      sharedArgs = {
        inherit inputs;
      };

      # 2. SHARED MODULES
      # Applied to every host in the fleet
      sharedModules = [
        # The Hub: Imports all your custom modules
        ./modules/default.nix
      ];

      forHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/${hostname}/default.nix
          ];
        };
    in
    {
      talos = forHost "talos";
      strix = forHost "strix";
      rog = forHost "rog";
      thinkpad = forHost "thinkpad";
      # Add more hosts here if needed
    };
}
