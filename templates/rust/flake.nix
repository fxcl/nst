{
  description = "nix shell for rust";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable; # unstable version of nixpkgs
    flake-utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, flake-utils, nixpkgs, rust-overlay, ... }:
    let
      overlays = [
        rust-overlay.overlays.default
      ];
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
        rust-version = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        # my-rust-bin = rust-version.override {
        #   # extensions = [ "rust-analyzer" "rust-src" ];
        # };

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [
            CoreFoundation
            CoreServices
            IOKit
            Security
          ]);
          packages = [
            pkgs.cargo-bloat
            rust-version
            # my-rust-bin
            # We want the unwrapped version, "rust-analyzer" (wrapped) comes with nixpkgs' toolchain

            pkgs.rust-analyzer-unwrapped
          ];
          shellHook = ''
            export BUCK2_BUILD_PROTOC=${pkgs.protobuf}/bin/protoc
            export BUCK2_BUILD_PROTOC_INCLUDE=${pkgs.protobuf}/include
          '';
          # See https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/3?u=samuela.
          #RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          RUST_SRC_PATH = "${rust-version}/lib/rustlib/src/rust/library";

          RUST_BACKTRACE = 1;

          RUSTUP_DIST_SERVER = "https://rsproxy.cn";
          RUSTUP_UPDATE_ROOT = "https://rsproxy.cn/rustup";
          RUSTUP_HOME = "/Users/kelvin/.local/share/rustup";
          CARGO_HOME = "/Users/kelvin/.local/share/cargo";
        };
      });
}
