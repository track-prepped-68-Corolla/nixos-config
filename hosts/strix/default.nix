{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:

let
  # Define the standard groups usually assigned to users (excluding wheel)
  commonGroups = [ "networkmanager" "docker" "incus-admin" "lp" "scanner" "printadmin" ];
in
{
  # ---------------------------------------------------------------------------
  # 1. Imports
  # ---------------------------------------------------------------------------
  imports = [
    ./hardware-configuration.nix
    ./../../modules/services/sddm.nix
    ./../../modules/services/printing
    ./../../modules/apps
    ./../../modules/desktops/plasma.nix
    ./../../modules/system/podman.nix
    ./../../modules/system/virt.nix
    ./../../modules/profiles/gaming.nix
    ./../../modules/themes/catppuccin.nix
  ];

  # ---------------------------------------------------------------------------
  # 2. Options
  # ---------------------------------------------------------------------------
  options = {
    superUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "joe" ];
      description = "List of users to be added to wheel and common groups";
    };

    normalUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of users to be added to common groups (excluding wheel)";
    };

    mainuser = lib.mkOption {
      type = lib.types.str;
      default = "joe";
      description = "The primary user (must be present in superUsers or normalUsers)";
    };
  };

  # ---------------------------------------------------------------------------
  # 3. Configuration
  # ---------------------------------------------------------------------------
  config = {

    # --- System Validation ---
    assertions = [
      {
        assertion = builtins.elem config.mainuser (config.superUsers ++ config.normalUsers);
        message = "The 'mainuser' (${config.mainuser}) must be listed in either 'superUsers' or 'normalUsers'.";
      }
    ];

    # --- Nix & System General ---
    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
      config.allowUnfree = true;
    };

    system.stateVersion = "25.05";

    environment.systemPackages = [
      pkgs.tailscale
      pkgs.kdePackages.krdc
    ];

    # --- Boot & Kernel ---
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      loader = {
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
        };
      };
    };

    # --- Networking ---
    networking = {
      hostName = "strix";
      networkmanager.enable = true;

      firewall = {
        allowedUDPPorts = [ config.services.tailscale.port ]; # Open Tailscale port
        allowedTCPPorts = [ 3389 ]; # Open RDP port
      };
    };

    # --- Hardware ---
    hardware.bluetooth.enable = true;

    # --- Services ---
    services = {
      openssh.enable = true;
      tailscale.enable = true;
      desktopManager.plasma6.enable = true;
    };

    # --- Virtualization & Modules ---
    modules = {
      podman.enable = true;
    };

    # --- User Configuration ---
    users.users = lib.mkMerge [
      # 1. Generate Superusers (Wheel + Common Groups)
      (lib.genAttrs config.superUsers (user: {
        isNormalUser = true;
        extraGroups = commonGroups ++ [ "wheel" ];
      }))

      # 2. Generate Normal Users (Common Groups only)
      (lib.genAttrs config.normalUsers (user: {
        isNormalUser = true;
        extraGroups = commonGroups;
      }))

      # 3. Hardcoded Admin User (Wheel only)
      {
        admin = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };
      }
    ];

    # --- Home Manager Configuration ---
    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      # Generate home-manager configs for ALL users (Supers, Normals, and Admin)
      users = lib.genAttrs (config.superUsers ++ config.normalUsers ++ [ "admin" ]) (user:
        ./../../home/users + "/${user}"
      );
    };
  };
}
