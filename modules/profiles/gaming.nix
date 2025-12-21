{ config, pkgs, lib, ... }:

{
  # Jovian-NixOS (Steam Deck UI/Optimizations)
  jovian.steam = {
    enable = true;
    autoStart = false;
    user = config.mainUser;
    desktopSession = "plasma";
  };
# Force sound.target to stay up and ignore 'destructive' stop requests during boot
systemd.targets.sound.unitConfig.DefaultDependencies = "no";

# Tell Jovian explicitly that we are not on an AMD handheld
# (This prevents it from loading the Deck's audio/video firmware logic)
jovian.hardware.has.amd.gpu = lib.mkForce false;
  # Standard Steam Client
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = false;
  };
}
