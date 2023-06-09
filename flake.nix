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
      cxx = {
        path = ./templates/cxx;
        description = "A development environment for Cpp.";

      };
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

      java-gradle = {
        path = ./java-gradle;
        description = "A development environment for java, gradle";
      };

      python-app = {
        path = ./python/app;
        description = "A development environment for Python App";
      };

      python-shell = {
        path = ./python/shell;
        description = "A development environment for Python Shell";
      };
    };
  };
}
