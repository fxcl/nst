{
  description = "nix shell for python";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mach-nix.follows = "mach-nix";
    };
    mach-nix = {
      url = "github:DavHau/mach-nix/3.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
    };
  };

  outputs = { self, flake-utils, nixpkgs, mach-nix, ... }:
    let
      overlays = [
      ];
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        machNix = mach-nix.lib.${system};

      in
      {
        devShells.default = pkgs.mkShell rec{
          buildInputs = with pkgs; [
            (machNix.mkPython {
              python = "python39";
              requirements = builtins.readFile ./requirements.txt;
            })

            pyright
          ];
        };
      });
}
