{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:

{
  # --- THE VARIABLE ---
  # Just change "joe" to "jen" here.
  # Everything else in the file will update automatically.
  options.mainUser = lib.mkOption {
    type = lib.types.str;
    default = "jen";
  };

  config = {
    imports = [
      ./hardware-configuration.nix
      ./../../modules/services/sddm.nix
      ./../../modules/desktops/plasma.nix
      # Only include what the Thinkpad actually has (e.g., maybe no Nvidia?)
      #./../../modules/system/virt.nix
      #./../../modules/themes/catppuccin.nix
    ];

    # --- HOST IDENTITY ---
    networking.hostName = "thinkpad";
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    nixpkgs.config.allowUnfree = true;

    # --- THE REST IS IDENTICAL ---
    # Because we use ${config.mainUser}, these blocks work for Joe OR Jen.
    users.users.${config.mainUser} = {
      isNormalUser = true;
      description = "Primary User Account";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      users.${config.mainUser} = ./../../Users + "/${config.mainUser}";
    };

    # Standard system stuff...
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };

    system.stateVersion = "25.05";
  };
}
