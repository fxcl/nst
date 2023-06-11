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
      pythonVersion = "python39";

    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mach = mach-nix.lib.${system};
        pythonEnv = mach.mkPython {
          python = pythonVersion;
          requirements = builtins.readFile ./requirements.txt;
        };

      in
      {
        devShells.default = pkgs.mkShellNoCC{
          buildInputs = with pkgs; [
            pythonEnv
            pyright
          ];

          shellHook = ''
            export PYTHONPATH="${pythonEnv}/bin/python"
          '';

        };
      });
}
