When writing a module, you should follow these guidelines:

- Use a tree like structure for the head lambda args if and only if it is
  needed.

```nix
{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  /* ommitted config */
}
```

- `imports` should do its best to avoid going backwards in the flake's file
  structure.
