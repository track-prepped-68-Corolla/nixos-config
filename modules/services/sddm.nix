{ config, pkgs, ... }:

{
  # You need this for SDDM and XKB settings to work!
  services.xserver.enable = true;

  # Enable the SDDM login manager
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # If you want to theme SDDM with Catppuccin
  # catppuccin.sddm.enable = true;
}
