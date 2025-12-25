{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:
{
  config = {
      environment.systemPackages = with pkgs; = [ 
      tailscale
      ];
  }
}
