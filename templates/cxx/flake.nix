{
  description = "nix shell for cpp";

  inputs = {
    zig.url = "github:mitchellh/zig-overlay";
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable; # unstable version of nixpkgs
    # nixpkgs.url = github:nixos/nixpkgs/release-22.11; # stable version of nixpkgs
    flake-utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, flake-utils, nixpkgs, ... }:
    let
      overlays = [
        # Other overlays
        (final: prev: {
          zigpkgs = inputs.zig.packages.${prev.system};
        })
      ];
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      {
        devShells.default = pkgs.mkShell rec{
          buildInputs = with pkgs; [
            clang
            cmake
            cmakeCurses

            spdlog
          ];
        };
      });
}
