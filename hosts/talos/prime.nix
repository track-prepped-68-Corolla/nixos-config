{ config, pkgs, ... }:

{
  # 1. Enable Graphics Support (modern replacement for hardware.opengl)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # 2. Load the NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Use the NVidia open source kernel module (not nouveau)
    # Supported on Turing (RTX 20-series) and newer.
    open = true;

    # Enable the Nvidia settings menu
    nvidiaSettings = true;

    # Modesetting is required for PRIME
    modesetting.enable = true;

    # PRIME Offloading Configuration
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Provides the `nvidia-offload` helper script
      };

      # Your converted Decimal Bus IDs
      amdgpuBusId = "PCI:35:0:0";
      nvidiaBusId = "PCI:45:0:0";
    };
  };
}