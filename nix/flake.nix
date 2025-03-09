{
description = "Flake configuration"

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
};

outputs = { nixpkgs, home-manager, ...}: {
  homeConfigurations."xkenshi" = home-manager.lib.homeManagerconfiguration {
    pkgs =  nixpkgs.legacyPackages.x86_64-linux;
    modules = [
      ./nix/.config/home-manager/home.nix
    ];
  };
};
}


}
