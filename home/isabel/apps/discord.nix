{ pkgs, ... }:
pkgs.discord.override {
  withMoonlight = true;
}
