{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "strix";

  # --- User Configuration ---
  modules.system.user.enable = true;
  mainuser = "joe";
  superUsers = [ "joe" ];

  # --- Modules ---
  modules.desktops.plasma.enable = true;
  modules.services.sddm.enable = true;

  # HARDWARE: Switched to AMD for Strix Halo 395
  modules.hardware.amd.enable = true;
  modules.services.printing.enable = true;

  # Gaming Profile
  modules.profiles.gaming.enable = true;

  modules.system.virt.enable = true;
  modules.system.podman.enable = true;
  modules.themes.catppuccin.enable = true;
}
