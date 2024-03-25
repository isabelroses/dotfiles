{
  flake.templates = {
    # C/C++
    c = {
      path = ./c;
      description = "Development environment for C/C++";
    };

    # golang
    go = {
      path = ./go;
      description = "Development environment for Golang";
    };

    # NodeJS
    node = {
      path = ./node;
      description = "Development environment for NodeJS";
    };

    # Python
    python = {
      path = ./python;
      description = "Development environment for Python";
    };

    # Rust
    rust = {
      path = ./rust;
      description = "Development environment for Rust";
    };
  };
}
