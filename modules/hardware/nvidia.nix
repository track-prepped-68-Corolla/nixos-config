{
  config,
  pkgs,
  lib,
  ...
}:

{
  # 1. Define the Option
  options.modules.hardware.nvidia = {
    enable = lib.mkEnableOption "NVIDIA proprietary drivers and optimizations";
  };

  # 2. Define the Config (Only runs if enable = true)
  config = lib.mkIf config.modules.hardware.nvidia.enable {

    # Enable 32-bit support (Steam, etc.)
    hardware.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    # Toggle the Podman integration we built earlier
    modules.system.podman.nvidia.enable = lib.mkDefault true;

    hardware.nvidia = {
      modesetting.enable = lib.mkDefault true;
      powerManagement = {
        enable = lib.mkDefault true;
        finegrained = lib.mkDefault false;
      };
      open = lib.mkDefault true;
      nvidiaSettings = lib.mkDefault true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };
}
