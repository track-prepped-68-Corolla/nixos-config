{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:

{
  # 1. Define the variable name
  options.mainUser = lib.mkOption {
    type = lib.types.str;
    default = "joe";
  };


  imports = [
    ./hardware-configuration.nix
    ./../../modules/services/sddm.nix
    ./../../modules/desktops/plasma.nix
    ./../../modules/hardware/nvidia.nix
    ./../../modules/system/virt.nix
    ./../../modules/profiles/gaming.nix
    ./../../modules/themes/catppuccin.nix
  ];

  # --- IDENTITY & HOST SPECIFICS ---
  networking.hostName = "rog";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- BOOT & KERNEL ---
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_17;

  # --- HARDWARE: BLUETOOTH & AUDIO ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- NETWORKING ---
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  systemd.network.wait-online.enable = false; # The 4.3s boot fix

  # --- USERS & HOME MANAGER ---
    users.users.${config.mainUser} = {
    isNormalUser = true;
    description = "Primary User Account";
    extraGroups = [ "networkmanager" "wheel" "docker" "incus-admin" "libvirtd" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.${config.mainUser} = ./../../Users + "/${config.mainUser}";
  };

  # --- SYSTEM PACKAGES & MISC ---
  environment.systemPackages = with pkgs; [
    wget ffmpeg unzip distrobox
  ];

  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
}
