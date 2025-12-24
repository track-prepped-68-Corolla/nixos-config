{ config, pkgs, ... }:

{
  # Jovian-NixOS (Steam Deck UI/Optimizations)
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = config.mainUser;
    desktopSession = "plasma";
  };

  # Standard Steam Client
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = false;
  };
}