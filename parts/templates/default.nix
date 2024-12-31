{
  flake.templates = {
    c = {
      path = ./c;
      description = "A C/C++ template";
    };

    cpp = {
      path = ./c;
      description = "A C/C++ template";
    };

    latex = {
      path = ./latex;
      description = "A LaTeX template";
    };

    go = {
      path = ./go;
      description = "A Golang template";
    };

    node = {
      path = ./node;
      description = "A NodeJS template";
    };

    python = {
      path = ./python;
      description = "A Python template";
    };

    rust = {
      path = ./rust;
      description = "A Rust template";
    };

    nix = {
      path = ./nix;
      description = "A Nix template";
    };
  };
}
