{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:
{
  config = {
      environment.systemPackages = with pkgs; = [ 
      pkgs.tailscale 
      pkgs.kdePackages.krdc
      ];
  }
}
