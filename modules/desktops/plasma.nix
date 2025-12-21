{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  programs.kdeconnect.enable = true;

  xdg.portal = {
  enable = true;
  extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.kdePackages.xdg-desktop-portal-kde
];
  config.common.default = "kde"; # This forces a default fallback
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

  # Optional: Exclude some default KDE bloat
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
  ];
}
