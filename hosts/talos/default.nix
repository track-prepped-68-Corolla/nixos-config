{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:

{
  # 1. Imports MUST be at the top level, outside of 'config'
  imports = [
          ./prime.nix
          ./hardware-configuration.nix
    ./../../modules/services/sddm.nix
    ./../../modules/desktops/plasma.nix
    ./../../modules/system/podman.nix
   #./../../modules/hardware/nvidia.nix
   #./../../modules/system/virt.nix
    ./../../modules/profiles/couchgaming.nix
    ./../../modules/themes/catppuccin.nix
  ];

#  modules = {
#    podman.enable = true;
#  };

  # 2. Options (Defining the variable)
  options.mainUser = lib.mkOption {
    type = lib.types.str;
    default = "joe";
  };

  # 3. Config (Setting the actual values)
  config = {
    # It is safe to also explicitly define this here just in case
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    networking.hostName = "talos";

    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };

    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # ... Include the rest of your settings (Networking, Users, etc.) here ...

    users.users.${config.mainUser} = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "docker" "incus-admin" "lp" "scanner" "printadmin" ];
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      users.${config.mainUser} = ./../../home/users + "/${config.mainUser}";
    };

    system.stateVersion = "25.05";
  };
}