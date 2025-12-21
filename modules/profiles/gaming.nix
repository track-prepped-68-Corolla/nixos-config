{ config, pkgs, ... }:

{
  # Jovian-NixOS (Steam Deck UI/Optimizations)
  jovian.steam = {
    enable = true;
    autoStart = false;
    user = config.mainUser;
    desktopSession = "cosmic";
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
