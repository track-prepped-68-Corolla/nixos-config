{
  description = "nixos config";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };

outputs = { self, nixpkgs, ... }@inputs: 

{

    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem{
        specialArgs = { inherit inputs; };
#        { nix.settings.experimental-features = ["nix-command" "flakes"]; }
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        {
           home.username = "joe";
           home.homeDirectory = "/home/joe";
           imports = [ ./home.nix ];
        }
      ];
    };

  };
  
}
