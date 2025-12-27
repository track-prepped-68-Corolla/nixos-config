{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./config/options.nix
    ./config/keymaps.nix
    ./config/plugins.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # We can enable the colorscheme here globally for the module
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };
  };
}
