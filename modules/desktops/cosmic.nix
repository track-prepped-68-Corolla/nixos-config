{ config, lib, pkgs, ... }:

{
  options.modules.desktops.cosmic = {
    enable = lib.mkEnableOption "COSMIC Desktop Environment";
  };

  config = lib.mkIf config.modules.desktops.cosmic.enable {

    services.desktopManager.cosmic.enable = lib.mkDefault true;
    services.displayManager.cosmic-greeter.enable = lib.mkDefault true;

    # Caching
    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };

    environment.sessionVariables = {
      COSMIC_DATA_CONTROL_ENABLED = "1";
    };

    services.system76-scheduler.enable = lib.mkDefault true;

    # Kernel parameters for Wayland/Nvidia
    boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
    hardware.graphics.enable = lib.mkDefault true;
  };
}
