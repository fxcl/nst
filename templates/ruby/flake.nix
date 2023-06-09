{
  description = "nix shell for ruby";

  inputs = {
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

        # example override in overlay
        (self: super: {
          ruby_3_1_jit = self.ruby_3_1.override { jitSupport = true; };
        })
      ];
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      {
        devShells.default =
          let
            gems = pkgs.bundlerEnv {
              ruby = pkgs.ruby_3_1;
              # ruby = pkgs.ruby_3_1_jit; # example of use custom ruby version from overlay
              name = "gems";
              gemdir = ./.;
            };
            ruby_env = pkgs.ruby_3_1.withPackages (ps: with ps; [ gems (pkgs.lib.lowPrio gems.wrappedRuby) ]);
            # ruby_env = pkgs.ruby_3_1_jit.withPackages (ps: with ps; [ gems (pkgs.lib.lowPrio gems.wrappedRuby) ]); # example of use custom ruby version from overlay
          in
          pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              bundix
              ruby_env
            ];
          };
      });
}
