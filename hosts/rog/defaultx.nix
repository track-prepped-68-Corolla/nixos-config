{
  config,
  pkgs,
  lib,
  catppuccin,
  home-manager,
  inputs,
  ...
}:

{
  # 1. Imports MUST be at the top level, outside of 'config'
  imports = [
    ./hardware-configuration.nix
    ./../../modules
  ];

  # 2. Options (Defining the variable)
  options.mainuser = lib.mkOption {
    type = lib.types.str;
    default = "joe";
  };

  # 3. Config (Setting the actual values)
  config = {

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

    # ... Include the rest of your settings (Networking, Users, etc.) here ...

    users.users.${config.mainuser} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "incus-admin"
        "lp"
        "scanner"
        "printadmin"
      ];
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      users.${config.mainuser} = ./../../home/users + "/${config.mainuser}";
    };

    system.stateVersion = "25.05";
  };
}
