# alias r := rebuild
# alias rr := remote-rebuild
# alias e := eval
# alias ea := eval-all
# alias u := update
# alias ui := update-input

flake_var := env_var('FLAKE')
flake := if flake_var =~ '^\.*$' { justfile_directory() } else { flake_var }
rebuild := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild" }

[private]
default:
    @just --list --unsorted

[group('rebuild')]
[private]
builder goal *args:
    sudo {{ rebuild }} {{ goal }} --flake {{ flake }} {{ args }} |& nom

# rebuild the boot
[group('rebuild')]
boot *args: (builder "boot" args)

# test what happens when you switch
[group('rebuild')]
test *args: (builder "test" args)

# switch the new system configuration
[group('rebuild')]
switch *args: (builder "switch" args)

[group('rebuild')]
[macos]
provision host:
    nix run github:LnL7/nix-darwin -- switch --flake {{ flake }}#{{ host }}
    sudo -i nix-env --uninstall lix # we need to remove the none declarative install of lix

# build the package, you must specify the package you want to build
[group('package')]
build pkg:
    nix build {{ flake }}#{{ pkg }} --log-format internal-json -v |& nom --json

# build the iso image, you must specify the image you want to build
[group('package')]
iso image: (build "nixosConfigurations." + image + ".config.system.build.isoImage")

# build the tarball, you must specify the host you want to build
[group('package')]
tar host:
    sudo nix run {{ flake }}#nixosConfigurations.{{ host }}.config.system.build.tarballBuilder

[group('dev')]
eval system *args="":
    nix eval \
      --no-allow-import-from-derivation \
      '{{ flake }}#nixosConfigurations.{{ system }}.config.system.build.toplevel' \
      {{ args }}

[group('dev')]
eval-all *args="":
    nix flake check --all-systems --no-build {{ flake }} {{ args }}

[group('dev')]
update:
    nix flake update \
      --refresh \
      --commit-lock-file \
      --commit-lockfile-summary "chore: update all inputs" \
      --flake {{ flake }}

[group('dev')]
update-input *input:
    nix flake update {{ input }} \
      --commit-lock-file \
      --commit-lockfile-summary "chore: update {{ input }}" \
      --flake {{ flake }}

[private]
verify *args:
    nix-store --verify {{ args }}

alias fix := repair

# repairs the nix store from any breakages it may have
[group('dev')]
repair: (verify "--check-contents --repair")

# clean the nix store and optimise it
[group('utils')]
clean:
    nh clean all -K 3d
    nix store optimise

[group('utils')]
[private]
oldclean:
    nix-collect-garbage --delete-older-than 3d
    nix store optimise

# check the flake for errors
[group('dev')]
check:
    nix flake check

# build & serve the docs locally
[group('dev')]
serve:
    nix run {{ flake }}#docs.serve
