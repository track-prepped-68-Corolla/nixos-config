{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:

{
  # 1. IMPORTS
  # Keep your existing module structure
  imports = [
    ./hardware-configuration.nix
    #./../../modules/services/sddm.nix
    ./../../modules/desktops/cosmic
    ./../../modules/hardware/nvidia.nix
    ./../../modules/system/virt.nix
    ./../../modules/system/podman.nix
    ./../../modules/profiles/gaming.nix
    ./../../modules/themes/catppuccin.nix
  ];

  # 2. USER CONFIGURATION (The "Input" Section)
  # Edit these lists to configure this specific host
  options.host = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "rog"; # [span_2](start_span)Your hostname[span_2](end_span)
    };
    mainUser = lib.mkOption {
      type = lib.types.str;
      default = "joe"; # [span_3](start_span)The primary user[span_3](end_span)
    };
    superUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "joe" ]; # Users with sudo/wheel
    };
    normalUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "guest" ]; # Users without sudo
    };
  };

  # 3. SYSTEM LOGIC (The "Template" Section)
  config = let
    # Helper to generate a basic user config
    mkUser = groups: {
      isNormalUser = true;
      extraGroups = [ "networkmanager" ] ++ groups;
    };
  in {
    
    # -[span_4](start_span)-- Boot & Hardware[span_4](end_span) ---
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_6_17; [span_5](start_span)#
    
    services.supergfxd.enable = false; #[span_5](end_span)

    # --- Networking ---
    networking.hostName = config.host.hostName;
    networking.networkmanager.enable = true;
    
    # --- Nix Config ---
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    nixpkgs.config.allowUnfree = true; [span_6](start_span)#
    system.stateVersion = "25.05";

    # --- DYNAMIC USER LOGIC ---
    
    # Logic: Validate that mainUser is actually in one of the lists
    assertions = [
      {
        assertion = (builtins.elem config.host.mainUser config.host.superUsers) || 
                    (builtins.elem config.host.mainUser config.host.normalUsers);
        message = "The mainUser '${config.host.mainUser}' must be listed in either superUsers or normalUsers.";
      }
    ];

    users.users = lib.mkMerge [
      # 1. The "Always There" Admin
      {
        admin = mkUser [ "wheel" "docker" "incus-admin" ]; # Admin gets all powers
      }

      # 2. Super Users (from list)
      (lib.genAttrs config.host.superUsers (user: 
        mkUser [ "wheel" "docker" "incus-admin" ] # Super users get your extra groups[span_6](end_span)
      ))

      # 3. Normal Users (from list)
      (lib.genAttrs config.host.normalUsers (user: 
        mkUser [ ] # Normal users only get "networkmanager" (defined in mkUser above)
      ))
    ];

    # --- HOME MANAGER LOGIC ---
    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      
      # Automatically generate home-manager configs for:
      # Admin + SuperUsers + NormalUsers
      users = lib.genAttrs 
        ([ "admin" ] ++ config.host.superUsers ++ config.host.normalUsers)
        (user: ./../../users + "/${user}"); # [span_7](start_span)Preserves your path logic[span_7](end_span)
    };
  };
}
