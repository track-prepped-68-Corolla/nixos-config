{ config, pkgs, lib, ... }:

{
  # Global Catppuccin settings
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
    cache.enable = true;
  };

  # Grub specific theme
  catppuccin.grub = {
    enable = true;
    flavor = "mocha";
  };

  # Fonts (often considered part of the "theme" or "aesthetic")
  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
