{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Note: Global modules are imported automatically via flake.nix
  ];

  # --- System Identity ---
  networking.hostName = "rog";

  # --- User Configuration ---
  # Enable the user module we just built
  modules.system.user.enable = true;

  # Define your personal user here.
  # Note: 'admin' is automatically added to this list by your user.nix module.
  superUsers = [ "joe" ];

  # Set the "primary" user for things like autologin or file ownership.
  # You can set this to "admin" if you prefer that as the default.
  mainuser = "joe";

  # --- Feature Modules ---

  # Desktop & Display
  modules.desktops.plasma.enable = true;
  modules.services.sddm.enable = true;

  # Hardware
  modules.hardware.nvidia.enable = true;
  modules.services.printing.enable = true;

  # Profiles
  modules.profiles.gaming.enable = true;

  # System Services
  modules.system.virt.enable = true;
  modules.system.podman.enable = true; # Nvidia support is auto-detected

  # Theming
  modules.themes.catppuccin.enable = true;
}
