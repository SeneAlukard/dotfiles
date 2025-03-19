{
  description = "XFCE desktop configuration with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";  # Adjust if you're using a different architecture
      pkgs = nixpkgs.legacyPackages.${system};
      username = "xkea";  # Replace with your username
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        # Pass additional parameters to modules if needed
        extraSpecialArgs = { };
        
        # Your home-manager configuration modules
        modules = [
          ./home.nix
        ];
      };
    };
}
