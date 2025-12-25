{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:
{
  config = {
      environment.systemPackages = with pkgs; = [ 
      nixos-generators
      tailscale
      wget
      curl
      unzip
      htop
      micro
      neovim
      git
      ];
  }
}
