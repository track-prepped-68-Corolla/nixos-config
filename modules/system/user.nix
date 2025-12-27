{ pkgs, lib, config, ... }:

let
  # Standard groups for all user accounts
  commonGroups = [
    "networkmanager"
    "docker"
    "podman"
    "incus-admin"
    "lp"
    "scanner"
    "printadmin"
    "video"
    "render"
  ];
in
{
  # 1. Options
  options = {

    # --- [NEW] The Missing Module Definition ---
    modules.system.user = {
      enable = lib.mkEnableOption "main user configuration";
    };

    # --- Your Custom User Lists ---
    superUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "admin" ];
      description = "List of users to be added to wheel and common groups";
    };

    normalUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of users to be added to common groups (excluding wheel)";
    };

    mainuser = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "The primary user (must be present in superUsers or normalUsers)";
    };
  };

  # 2. Configuration (Gated by the enable switch)
  config = lib.mkIf config.modules.system.user.enable {

    # Generate User Configurations
    users.users = lib.mkMerge [

      # SUPER USERS (Wheel + Common)
      (lib.genAttrs (lib.unique (config.superUsers ++ [ "admin" ])) (user: {
        isNormalUser = true;
        extraGroups = commonGroups ++ [ "wheel" ];
        # initialPassword = "password";
      }))

      # NORMAL USERS (Common Only)
      (lib.genAttrs config.normalUsers (user: {
        isNormalUser = true;
        extraGroups = commonGroups;
      }))
    ];
  };
}
