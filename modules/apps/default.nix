{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:
{
  config = {
      environment.systemPackages = [ 
      pkgs.tailscale 
      pkgs.kdePackages.krdc
      ];
  }
}
