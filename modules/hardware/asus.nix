{ config, lib, pkgs, ... }:

{
  options.modules.hardware.asus = {
    enable = lib.mkEnableOption "ASUS ROG/TUF Hardware Support";
  };

  config = lib.mkIf config.modules.hardware.asus.enable {

    services.asusd = {
      enable = true;
      enableUserService = true;
    };

    # 2. System Packages (CLI control for asusd)
    environment.systemPackages = with pkgs; [
      asusctl             # CLI tool
      #rog-control-center  # GUI (rogcc)
    ];
  };
}
