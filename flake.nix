{
  description = "Home Manager configuration of michaelwebb";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-24.11-darwin";
      # Pin to a specific revision that has the packages we need in the cache
      # Remove this line when the nix cache is fixed
      rev = "86484f6076aac9141df2bfcddbf7dcfce5e0c6bb";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."michaelwebb" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
