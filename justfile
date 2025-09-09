flake := env('FLAKE', justfile_directory())

# rebuild is also set as a var so you can add --set to change it if you need to

rebuild := if os() == "macos" { "sudo darwin-rebuild" } else { "nixos-rebuild" }
system-args := if os() != "macos" { "--sudo --no-reexec --log-format internal-json" } else { "" }
nom-cmd := if os() == "macos" { "nom" } else { "nom --json" }

[private]
default:
    @just --list --unsorted

# rebuild group

[group('rebuild')]
[private]
builder goal *args:
    {{ rebuild }} {{ goal }} \
      --flake {{ flake }} \
      {{ system-args }} \
      {{ args }} \
      |& {{ nom-cmd }}

[group('rebuild')]
deploy host *args: (builder "switch" "--target-host " + host "--use-substitutes " + args)

[group('rebuild')]
deploy-all:
  just deploy minerva
  just deploy aphrodite
  just deploy skadi

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

# package group

# build the package, you must specify the package you want to build
[group('package')]
build pkg:
    nix build {{ flake }}#{{ pkg }} \
      --log-format internal-json \
      -v \
      |& nom --json

# build the iso image, you must specify the image you want to build
[group('package')]
iso image: (build "nixosConfigurations." + image + ".config.system.build.isoImage")

# build the tarball, you must specify the host you want to build
[group('package')]
tar host:
    sudo nix run {{ flake }}#nixosConfigurations.{{ host }}.config.system.build.tarballBuilder

# dev group

# check the flake for errors
[group('dev')]
check:
    nix flake check --no-allow-import-from-derivation

[group('dev')]
repl-host host=`hostname`:
    nix repl .#nixosConfigurations.{{ host }}

# update a set of given inputs
[group('dev')]
update *input:
    nix flake update {{ input }} \
      --refresh \
      --commit-lock-file \
      --commit-lockfile-summary "flake.lock: update {{ if input == "" { "all inputs" } else { input } }}" \
      --flake {{ flake }}

# build & serve the docs locally
[group('dev')]
serve:
    nix run {{ flake }}#docs.serve

# push to the mirrors
[group('dev')]
push-mirrors:
    git push git@gitlab.com:isabelroses/dotfiles.git
    git push --mirror ssh://git@codeberg.org/isabel/dotfiles.git
    git push --mirror git@tangled.sh:isabelroses.com/dotfiles

# utils group

alias fix := repair

# verify the integrity of the nix store
[group('utils')]
verify *args:
    nix-store --verify {{ args }}

# repairs the nix store from any breakages it may have
[group('utils')]
repair: (verify "--check-contents --repair")

# clean the nix store and optimise it
[group('utils')]
clean:
    nix-collect-garbage --delete-older-than 3d
    nix store optimise
