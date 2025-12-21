{ config, pkgs, lib, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  programs.kdeconnect.enable = true;

  environment.sessionVariables = {
  KSCREEN_BACKEND = "none";
  KSCREEN_BACKEND_INPROCESS = "1";
};


  # KDE-specific system packages
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.spectacle # Screenshot tool
    kdePackages.partitionmanager
  ];

  # Configure KWallet to unlock on login
  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };

xdg.portal = {
  enable = true;
  # Force KDE to be the ONLY portal provider to stop the conflict
  extraPortals = lib.mkForce [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  config.common.default = "kde";
};

  # Optional: Exclude some default KDE bloat
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
  ];
}
