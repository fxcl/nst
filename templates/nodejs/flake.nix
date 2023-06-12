{
  description = "nix shell for nodejs";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    language-servers.url = "git+https://github.com/fxcl/language-servers.nix";

  };

  outputs = { self, flake-utils, nixpkgs, ... }:
    let
      overlays = [
      ];
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      {
        devShells.default = pkgs.mkShell rec{
          nativeBuildInputs = with pkgs; [
            # standard toolkit
            nodejs-16_x # nixpkgs provides a "nodejs" package that corresponds to the current LTS version of nodejs, but you can specify a version (i.e node_20) if necessary
            yarn
            pnpm # a faster alternative to npm and yarn, with a less adopted toolchain

            # optionally required by your code editor to lint and format your code
            nodePackages.prettier # formatter
            nodePackages.eslint # linter

            # example package to serve a static nextjs export
            nodePackages.serve

            nodePackages.npm
            #nodePackages.typescript-language-server
            language-servers.packages.${system}.angular-language-server
            language-servers.packages.${system}.svelte-language-server
            language-servers.packages.${system}.typescript-language-server
            language-servers.packages.${system}.vscode-langservers-extracted
          ];
        };
      });
}
