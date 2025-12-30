{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.modules.hardware.amd = {
    enable = lib.mkEnableOption "AMD GPU/APU configuration";
  };

  config = lib.mkIf config.modules.hardware.amd.enable {

    # 1. Driver
    services.xserver.videoDrivers = [ "amdgpu" ];

    # 2. Kernel (Strix Halo is bleeding edge, so we default to latest kernel)
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # 3. Graphics / OpenGL (Essential for Plasma & Gaming)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # 4. Hardware acceleration for video
    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
    ];
  };
}
