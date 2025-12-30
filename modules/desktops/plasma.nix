{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.modules.desktops.plasma = {
    enable = lib.mkEnableOption "KDE Plasma Desktop";
  };

  config = lib.mkIf config.modules.desktops.plasma.enable {

    services.xserver.enable = lib.mkDefault true;
    services.desktopManager.plasma6.enable = lib.mkDefault true;
    programs.kdeconnect.enable = lib.mkDefault true;

    # KDE-specific system packages
    environment.systemPackages = with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
      kdePackages.spectacle
      kdePackages.partitionmanager
      kdePackages.krdc
    ];

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
    ];

    security.pam.services.kwallet = {
      name = "kwallet";
      enableKwallet = lib.mkDefault true;
    };
  };
}
