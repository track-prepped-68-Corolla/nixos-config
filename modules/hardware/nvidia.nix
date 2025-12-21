{ config, pkgs, ... }:

{
  # Enable OpenGL / Hardware Acceleration
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # Enable Nvidia Container Toolkit (for Docker/Incus)
  hardware.nvidia-container-toolkit.enable = true;

boot.kernelParams = [
  # 1. Display & Graphics Priority
  "nvidia-drm.modeset=1"
  "nvidia-drm.fbdev=0"        # Keeps Nvidia away from boot console to prevent the hang
  "video=eDP-1:2560x1600@165" # Defines internal screen resolution
  "video=eDP-1:e"             # FORCES internal screen to 'Enabled'
  "video=DP-2:d"              # FORCES ghost XG-Mobile port to 'Disabled'

  # 2. Hardware Stability & Power
  "pcie_port_pm=off"          # Critical for ASUS ROG PCIe bus stability
  "random.trust_cpu=on"      # Prevents the entropy/seeding hang
  "bluetooth.disable_ertm=y" # Fixes the MediaTek/Intel Bluetooth firmware stall

  # 3. Pathing
  "firmware_class.path=/run/current-system/sw/lib/firmware"
];

  services.xserver.displayManager.setupCommands = ''
  ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --off
'';

boot.plymouth.enable = false;

systemd.services.nvidia-powerd.enable = false;

# And for the Nvidia driver specifically:
services.xserver.deviceSection = ''
  Option "IgnoreDisplayDevices" "DP-2"
'';

boot.extraModprobeConfig = ''
  # Try the Open-driver specific naming convention
  options nvidia ignore_display_devices=DP-2

  # Ensure Bluetooth doesn't stall the PCIe bus
  options bluetooth disable_ertm=1
'';

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
}
