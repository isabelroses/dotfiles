_: {
  flake.templates = {
    c = {
      path = ./c; # C/C++
      description = "Development environment for C/C++";
    };

    rust = {
      path = ./rust; # Rust
      description = "Development environment for Rust";
    };

    node = {
      path = ./node; # NodeJS
      description = "Development environment for NodeJS";
    };

    go = {
      path = ./go; # golang
      description = "Development environment for Golang";
    };

    python = {
      path = ./python; # Python
      description = "Development environment for Python";
    };
  };
}
