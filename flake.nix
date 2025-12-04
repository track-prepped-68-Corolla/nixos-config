{
  description = "nixos config";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      catppuccin.url = "github:catppuccin/nix";
      catppuccin.inputs.nixpkgs.follows = "nixpkgs";

      jovian-nixos.url = "github:jovian-experiments/jovian-nixos";

      nixos-hardware.url = "github:track-prepped-68-Corolla/nixos-hardware";

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };

outputs = { self, nixpkgs, catppuccin, home-manager, jovian-nixos, nixos-hardware, ... }@inputs:

{

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem{
        specialArgs = { inherit inputs catppuccin home-manager jovian-nixos nixos-hardware; };

      modules = [
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        jovian-nixos.nixosModules.default
        # PLACEHOLDER! DO NOT UNCOMMENT UNTIL YOU'VE POINTED THIS AT THE CORRECT SYSTEM!
        #nixos-hardware.nixosModules.dell-xps-13-9380
        {nix.settings.experimental-features = ["nix-command" "flakes"];}
      ];
    };

  };

}
