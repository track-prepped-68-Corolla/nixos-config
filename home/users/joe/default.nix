{ config, pkgs, inputs, ... }:

{
  # --- Imports ---
  imports = [
    # Import our custom Nixvim module
    ../../home-modules/nixvim/default.nix
  ];

  # --- User Information ---
  home.username = "joe";
  home.homeDirectory = "/home/joe";

  # State Version: Do not change unless you read release notes
  home.stateVersion = "25.11";

  # --- Program Configuration ---
  programs.home-manager.enable = true;

  # Allow unfree packages (Chrome, Discord, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable generic Linux support (useful if using non-NixOS Linux)
  targets.genericLinux.enable = true;

  xdg.enable = true;

  # --- Configuration Files ---
  # Distrobox configuration
  xdg.configFile."distrobox/distrobox.conf".text = ''
    # Mount the Nix Store so your host's CLI tools work inside the container
    container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro"
  '';

  # --- Environment Variables ---
  home.sessionVariables = {
    # EDITOR = "nvim"; # Nixvim sets defaultEditor = true, so this isn't strictly needed
  };

  # --- Packages ---
  home.packages = with pkgs; [

    # SYSTEM / CLI TOOLS
    fastfetch
    htop
    micro
    yazi
    nixfmt-rfc-style
    oh-my-posh
    tmux

    # DESKTOP APPS
    brave
    kitty
    signal-desktop
    slack
    localsend

    # DEVELOPMENT
    gitFull
    github-desktop
    vscodium
    distrobox # Useful to have installed if using the config above

    # CREATIVE & OFFICE
    krita
    openscad
    freecad
    blender
    onlyoffice-desktopeditors

    # GAMING
    mangohud
    heroic
    lutris

    # Custom Discord (with Vencord/OpenASAR)
    (pkgs.discord.override {
      withOpenASAR = true;
      enableAutoscroll = true;
      withMoonlight = true;
    })
  ];
}
