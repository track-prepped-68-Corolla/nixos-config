{ config, pkgs, ... }:

{

  services.xserver.enable = true;

  services.desktopManager.plasma6.enable = true;

  programs.kdeconnect.enable = true;

  # KDE-specific system packages
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.spectacle # Screenshot tool
    kdePackages.partitionmanager
    kdePackages.krdc
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
  ];

  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };

}
