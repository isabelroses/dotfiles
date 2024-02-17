{
  flake.templates = {
    # C/C++
    c = {
      path = ./c;
      description = "Development environment for C/C++";
    };

    # Rust
    rust = {
      path = ./rust;
      description = "Development environment for Rust";
    };

    # NodeJS
    node = {
      path = ./node;
      description = "Development environment for NodeJS";
    };

    # golang
    go = {
      path = ./go;
      description = "Development environment for Golang";
    };

    # Python
    python = {
      path = ./python;
      description = "Development environment for Python";
    };
  };
}
