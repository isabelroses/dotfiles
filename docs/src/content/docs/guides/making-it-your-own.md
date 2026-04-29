---
title: Making it your own
description: A guide for adapting this configuration to your own systems.
---

Despite my best efforts to advise against it, many of you still choose to do
so. So here is a guide on how to make it your own.

## Steps

1. There are a number of files you'll want to edit, but the best place to start is renaming the `isabel` user to your own user.
2. User configuration:
   1. Edit `/modules/base/users/options.nix` and change any mentions of `isabel` to your username.
   2. Create a file that will contain your SSH key at `/modules/base/users/<user>.nix`.
   3. Edit `/modules/nixos/users/<user>.nix` to add your encrypted password, generated with `mkpasswd`.
3. Picking a host:
   1. I host a number of different types of hosts, so there is likely one that will nicely match yours. To check what is a good match for you, look at [the hosts table](/design/topology/#systems).
   2. Once you've picked the ideal host, rename `/systems/<old>/` to your preferred hostname.
   3. Update the matching entry in `nixosConfigurations` (or `darwinConfigurations`) in `/modules/flake/default.nix` so the name lines up. See [Adding systems](/guides/adding-systems/) for the available options.
   4. Make any needed adjustments. This should include renaming the home-manager users and configuring the options.
4. Edit `modules/nixos/environment/locale.nix` so that you have the correct timezone and locale.
5. You likely don't want to use my Lix fork, so regex-replace `izlix` with your preferred Nix implementation. If your preferred Nix implementation does not support nested `input.follows` you'll have to edit the `flake.nix`.
6. There is a lot of maintenance burden in this repository, so see what you can remove safely. There's no safe way to guide you on this — best of luck.
