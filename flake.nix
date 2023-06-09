{
  description = "My flake templates";

  inputs = { };
  outputs = { self, ... }: {
    description = "nix shell templates for development environment, compatible with nix-shell and nix develop";

    defaultTemplate = {
      path = ./templates/default;
      description = "Empty template";
    };

    templates = {
      zig = {
        path = ./templates/zig;
        description = "A development environment for Zig.";
      };
      ruby = {
        path = ./templates/ruby;
        description = "A development environment for Ruby.";
      };
      rust = {
        path = ./templates/rust;
        description = "A development environment for Rust.";
      };

      java-gradle-empty = {
        path = ./java-gradle-empty;
        description = "A development environment for java, gradle";
      };

      java-maven-empty = {
        path = ./java-maven-empty;
        description = "A development environment for java, maven";
      };
    };
  };
}
