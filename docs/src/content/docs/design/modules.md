---
title: Modules
description: Conventions for writing modules in this flake.
---

## Introduction

When writing a module, you should follow these guidelines:

### Module Headers


Use a tree-like structure for the head lambda args if and only if it is needed.

  ```nix
  {
    lib,
    pkgs,
    inputs,
    ...
  }:
  {
    # omitted config
  }
  ```

### File Structure

Every use of `imports` should make a good attempt not to use `../` (going up in
the file structure). I would like to have a simple file structure and this
helps achieve that.

### Lib Usage

When using lib you should ideally be as specific as possible. This may look
like moving from `lib.mkOption` to `lib.options.mkOption`.
