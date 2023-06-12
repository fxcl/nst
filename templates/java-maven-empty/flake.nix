{
  description = "nix shell for java & maven";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    language-servers.url = "git+https://github.com/fxcl/language-servers.nix";


  };

  outputs = { self, flake-utils, nixpkgs, language-servers, ... }:
    let
      overlays = [
      ];
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
        my-jdk = pkgs.jdk17;
        my-maven = pkgs.maven.override { jdk = my-jdk; };

      in
      {
        devShells.default = pkgs.mkShell rec{
          nativeBuildInputs = with pkgs; [
            my-jdk
            my-maven
            language-servers.packages.${system}.jdt-language-server
            maven
          ];
          # Maybe uncomment this line for working with unsecure Maven repositories.
          #MAVEN_OPTS="-Dmaven.wagon.http.ssl.insecure=true";
        };
      });
}
