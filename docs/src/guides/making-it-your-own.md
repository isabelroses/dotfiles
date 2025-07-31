Despite my best efforts to advice you as to not do this, many of you still
choose to do so. So here is a guide on how to make it your own. So maybe
consider donating to me before continuing.

donation platforms in order of preference:
- [ko-fi](https://ko-fi.com/isabelroses)
- [github sponsors](https://github.com/sponsors/isabelroses)
- [liberapay](https://liberapay.com/isabelroses)
- [patreon](https://www.patreon.com/isabelroses)

# Making it your own

1. There are a number of files you will want to edit but the best place to
   start would be renaming the `isabel` user to your own user and deleting the
   robin user.
2.
  1. Following this you will want to edit `/modules/base/users/options.nix` and
   change any mentions of `isabel` to your username.
  2. Then you can create a file in that will contain your ssh key
     `/modules/base/users/<user>.nix`.
  3. Finally you will want to edit `/modules/nixos/users/<user>.nix` to add
     your encrypted password, generated with `mkpasswd`.
3.
  1. I host a number off different types of hosts, so there is likely one that
   will nicely match yours. To check what is a good match for you, look at [the
   hosts table](/design/layout.html#-systems).
  2. At this point you should have found the ideal host, so your going to
     rename the directory that it is into your preferred hostname.
  3. Then you should make any needed adjustments. This should include renaming
     the home-manager users and configuring the options.
4. You will then want to edit `modules/nixos/environment/locale.nix` such that
   you have the correct timezone and locale.
5. You likely don't want to use my lix fork, so you should regex replace
   `izlix` with your preferred nix implementation. If your preferred nix
   implementation does not support nested `input.follows` you will have to edit
   the `flake.nix`.
6. There is a lot of maintenance burden in this repository, so you should see
   what you can remove safely. But there's no safe way to guide you on this so best of luck.

