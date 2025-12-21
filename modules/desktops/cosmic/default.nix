{ config, lib, pkgs, ... }:

{
  options.my-desktop.cosmic.enable = lib.mkEnableOption "COSMIC Desktop Environment";

  config = lib.mkIf config.my-desktop.cosmic.enable {
    # 1. Enable the core COSMIC Desktop
    services.desktopManager.cosmic.enable = true;

    # 2. Enable the COSMIC Login Manager (Greeter)
    services.displayManager.cosmic-greeter.enable = true;

    # 3. Add the COSMIC binary cache (Crucial for Rust builds)
    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };

    # 4. Optional: Recommended fixes for current COSMIC versions
    environment.sessionVariables = {
      # Fixes clipboard issues in some Wayland apps
      COSMIC_DATA_CONTROL_ENABLED = "1";
    };

    # Experimental: System76 scheduler improves desktop snappiness
    services.system76-scheduler.enable = true;

    # Ensure your kernel handles Wayland/Nvidia correctly if applicable
     boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  };
}
