{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:

let
  # Define the standard groups usually assigned to users (excluding wheel)
  commonGroups = [ "networkmanager" "docker" "incus-admin" "lp" "scanner" "printadmin" ];
in
{
  # 1. Imports MUST be at the top level, outside of 'config'
  imports = [
    ./hardware-configuration.nix
    ./../../modules
  ];

  # 2. Options (Defining the variables)
  options = {
    superUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
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

  # 3. Config (Setting the actual values)
  config = {

    # Validation: Ensure the selected mainuser is actually in one of the provided lists
    assertions = [
      {
        assertion = builtins.elem config.mainuser (config.superUsers ++ config.normalUsers);
        message = "The 'mainuser' (${config.mainuser}) must be listed in either 'superUsers' or 'normalUsers'.";
      }
    ];

    # 1. Install the Tailscale package
    environment.systemPackages = [ 
      pkgs.tailscale 
      pkgs.kdePackages.krdc
    ];

    # 2. Enable the Tailscale daemon
    services.tailscale.enable = true;

    services.openssh.enable = true;

    # 3. Open the firewall for Tailscale's default port
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

    modules = {
      podman.enable = true;
    };

    # It is safe to also explicitly define this here just in case
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    hardware.bluetooth.enable = true;

    networking.hostName = "rog";

    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };

    services = {
      supergfxd.enable = false;
    };

    services.desktopManager.plasma6.enable = true;

    # Open the RDP port in the firewall
    networking.firewall.allowedTCPPorts = [ 3389 ];

    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

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

    system.stateVersion = "25.05";
  };
}
