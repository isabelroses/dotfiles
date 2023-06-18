{
  shellCommands = [
    {
      help = "Run the configured formatter (default: alejandra)";
      name = "fmt";
      command = "nix fmt";
    }

    {
      package = "alejandra";
      category = "formatter";
    }
    {
      package = "nixpkgs-fmt";
      category = "formatter";
    }
  ];

  env = [
    {
      name = "FLAKE";
      value = builtins.exec "pwd";
    }
  ];
}
