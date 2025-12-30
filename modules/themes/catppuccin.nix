{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.modules.themes.catppuccin = {
    enable = lib.mkEnableOption "Catppuccin global theme";
  };

  config = lib.mkIf config.modules.themes.catppuccin.enable {

    catppuccin = {
      enable = lib.mkDefault true;
      flavor = lib.mkDefault "mocha";
      accent = lib.mkDefault "mauve";
      cache.enable = true;
    };

    catppuccin.grub = {
      enable = lib.mkDefault true;
      flavor = lib.mkDefault "mocha";
    };

    fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };
}
