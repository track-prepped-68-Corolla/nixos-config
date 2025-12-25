{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:
{
  config = {
      environment.systemPackages = with pkgs; = [ 
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
