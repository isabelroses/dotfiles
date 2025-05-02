let
  compat = fetchTarball {
    url = "https://git.lix.systems/lix-project/flake-compat/archive/6588972962297c7abd300a72c55b2c7e21c1dc54.tar.gz";
    sha256 = "sha256-PplvwAEkj+/MFkM6Q9V59L6f6i3Tbdc/9yLRf/iwECg=";
  };

  flake = import compat { src = ./.; };
in
flake.shellNix
