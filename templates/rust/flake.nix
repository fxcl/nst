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

    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };

  };

  outputs = { self, flake-utils, nixpkgs, crane, advisory-db, rust-overlay, ... }:
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

        rustStable =
          pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        craneLib = (crane.mkLib pkgs).overrideToolchain rustStable;

        commonArgs = {
          src = craneLib.cleanCargoSource ./.;
          buildInputs = [ ];
          nativeBuildInputs = [ ];
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        };
        cargoArtifacts = craneLib.buildDepsOnly (commonArgs // { doCheck = false; });

        my-rust-package = craneLib.buildPackage (commonArgs // { doCheck = false; });
        my-rust-package-clippy = craneLib.cargoClippy (commonArgs
          // {
          inherit cargoArtifacts;
        });
        my-rust-package-fmt = craneLib.cargoFmt (commonArgs // { });
        my-rust-package-audit = craneLib.cargoAudit (commonArgs // { inherit advisory-db; });
        my-rust-package-nextest = craneLib.cargoNextest (commonArgs
          // {
          inherit cargoArtifacts;
          src = ./.;
          partitions = 1;
          partitionType = "count";
        });

      in
      {
        checks = {
          inherit my-rust-package my-rust-package-audit my-rust-package-clippy my-rust-package-fmt my-rust-package-nextest;
        };

        packages.default = my-rust-package;

        apps.default = flake-utils.lib.mkApp { drv = my-rust-package; };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.checks;
          buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.IOKit
            darwin.apple_sdk.frameworks.Security
            stdenv.cc.cc.lib
            pkgconfig
            openssl
            libiconv
          ]
          );

          nativeBuildInputs = with pkgs; [
            cargo-nextest
            cargo-release
            rustStable
            #rust-analyzer-unwrapped
          ];

          shellHook = ''
            export PS1="[$name] \[$txtgrn\]\u@\h\[$txtwht\]:\[$bldpur\]\w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty \[$bldylw\]\$aws_env\[$txtrst\]\$ "
            export NIX_LDFLAGS="-F${pkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS";
          '';

          # See https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/3?u=samuela.
          #RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          RUST_SRC_PATH = "${rust-version}/lib/rustlib/src/rust/library";
          RUST_BACKTRACE = 1;
          RUSTUP_DIST_SERVER = "https://rsproxy.cn";
          RUSTUP_UPDATE_ROOT = "https://rsproxy.cn/rustup";
          RUSTUP_HOME = "/Users/kelvin/.local/share/rustup";
          CARGO_HOME = "/Users/kelvin/.local/share/cargo";
          CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
        };
      });
}
