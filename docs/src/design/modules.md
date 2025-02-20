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

- Always use the full path to the `lib` you are using. e.g.,
  `lib.option.mkOption` instead of `lib.mkOption`.

- `imports` should do its best to avoid going backwards in the flake's file
  structure.
