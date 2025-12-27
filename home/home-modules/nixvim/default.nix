{ inputs, ... }:
{
  imports = [
    # [FIX] Renamed from 'homeManagerModules' to 'homeModules'
    inputs.nixvim.homeModules.nixvim

    ./config/options.nix
    ./config/keymaps.nix
    ./config/plugins.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };
  };
}
