#!/usr/bin/env nu

# https://shonk.social/notes/9tb5t1rq51z100n4
let nodes = open flake.lock | from json | get nodes
let lockChannelName = $nodes | get root | get inputs | get nixpkgs
let lockState = $nodes | get $lockChannelName | get locked |  get rev | str substring 0..7
let systemState = nixos-version | split row '.' | get 3 | split row ' ' | first
echo $"the lockfile in on commit ($lockState)"
echo $"the system is on commit ($systemState)"
if $lockState == $systemState {
  echo $"(ansi green)the system State and the lock file are on the same commit hash(ansi reset)"
  exit 0
} else {
  echo $"(ansi red)the system State and the lock file are (ansi rb)NOT(ansi reset)(ansi red) on the same commit hash(ansi reset)"
  exit 1
}
