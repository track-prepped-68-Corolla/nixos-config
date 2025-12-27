{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "thinkpad";

  # --- User Configuration ---
  modules.system.user.enable = true;
  mainuser = "jen";
  superUsers = [ "jen" ];

  # --- Modules ---
  modules.desktops.plasma.enable = true;
  modules.services.sddm.enable = true;
  modules.services.printing.enable = true;
  modules.themes.catppuccin.enable = true;
}
