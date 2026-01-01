{
  config,
  pkgs,
  lib,
  catppuccin,
  home-manager,
  inputs,
  ...
}:
{
  config = {
    environment.systemPackages = with pkgs; [
      nixos-generators
      sops
      wget
      curl
      unzip
      htop
      micro
      neovim
      lazygit
      ripgrep
      fd
      fzf
      git
    ];
  };
}
