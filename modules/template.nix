{ pkgs, lib, config, ... }:

{
  options.module.changeme = {
    enable = lib.mkEnableOption "Enable your shiny new module";
  };

  config = lib.mkIf config.module.changeme.enable {

  };
}
