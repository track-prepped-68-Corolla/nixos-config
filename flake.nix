{
  description = "NixOS Configuration";

#test comment

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

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # 1. SHARED ARGUMENTS
      # Makes 'inputs' available to all modules
      sharedArgs = {
        inherit inputs;
        inherit (inputs) catppuccin home-manager jovian-nixos nixos-hardware;
      };

      # 2. SHARED MODULES
      # Applied to every host in the fleet
      sharedModules = [
        # The Hub: Imports all your custom modules
        ./modules/default.nix

        # External Inputs
        inputs.home-manager.nixosModules.default
        inputs.sops-nix.nixosModules.sops
        inputs.catppuccin.nixosModules.catppuccin
        inputs.stylix.nixosModules.stylix
        inputs.nixos-cosmic.nixosModules.default
        inputs.jovian-nixos.nixosModules.default

        # --- GLOBAL CONFIGURATION ---
        {
          config = {
            # 1. System Basics
            system.stateVersion = "25.05";
            nixpkgs.config.allowUnfree = true;

            # --- CONNECTIVITY ---
            networking.networkmanager.enable = true;

            # Enable Bluetooth & Power it up on boot
            hardware.bluetooth = {
              enable = true;
              powerOnBoot = true;
            };

            # 2. Localization (US/NY)
            time.timeZone = "America/New_York";
            i18n.defaultLocale = "en_US.UTF-8";

            # 3. Global Bootloader (GRUB for UEFI)
            # We explicitly disable systemd-boot to avoid conflicts with auto-generated hardware configs
            boot.loader = {
              systemd-boot.enable = false;

              grub = {
                enable = true;
                efiSupport = true;
                device = "nodev";
                useOSProber = true;
              };

              efi.canTouchEfiVariables = true;
            };

            # 4. Nix Settings & Caches
            nix.settings = {
              experimental-features = [ "nix-command" "flakes" ];
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };

            # 5. Home Manager Integration
            home-manager.sharedModules = [
              inputs.plasma-manager.homeModules.plasma-manager
            ];
          };
        }
      ];
    in
    {
      nixosConfigurations = {

        # --- Host: ROG (ASUS Flow) ---
        rog = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/rog/default.nix
            inputs.nixos-hardware.nixosModules.asus-flow-gz301vu
          ];
        };

        # --- Host: Thinkpad (T14 AMD) ---
        thinkpad = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/thinkpad/default.nix
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
          ];
        };

        # --- Host: Talos ---
        talos = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/talos/default.nix
          ];
        };

        # --- Host: Strix (Strix Halo) ---
        strix = nixpkgs.lib.nixosSystem {
          specialArgs = sharedArgs;
          modules = sharedModules ++ [
            ./hosts/strix/default.nix
          ];
        };

      };
    };
}
