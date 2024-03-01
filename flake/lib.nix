{inputs, ...}: {
  flake.lib = import (inputs.self + /lib) {inherit inputs;};
}
