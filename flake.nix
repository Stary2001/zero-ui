{
  outputs = { self, nixpkgs }: with nixpkgs.lib; rec {
    packages = mapAttrs (system: pkgs: {
      default = pkgs.callPackage ./yarn-project.nix { } {
        src = ./.;
        overrideAttrs = ( oldAttrs: {
          buildPhase = "yarn build";
          dontStrip = true;
        } );
      };
    }) { "x86_64-linux" = nixpkgs.legacyPackages.x86_64-linux; };

    nixosModules.default = import ./module.nix self;
  };
}
