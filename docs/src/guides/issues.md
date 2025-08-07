# Issues

A awesome list of issues I've had that I want to document for future reference.


## chmod nix darwin error

`error: chmod '"/nix/store/66kaihiqnn02vpxs6qydcbw9pq7nrkld-iterm2-3.5.4/Applications/iTerm2.app"': Operation not permitted`

You can get this error when trying to run `nix store gc`. The fix for this is
to give nix FDA. To do so `System Settings > Privacy & Security > Full Disk
Access` and add nix to the list of apps that have full disk access.

See also https://github.com/NixOS/nix/issues/6765
