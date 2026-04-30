import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import starlightCatppuccin from '@catppuccin/starlight'

export default defineConfig({
  site: "https://dotfiles.isabelroses.com",
  integrations: [
    starlight({
      title: "isabel's dotfiles",
      description: "isabel's personal NixOS, nix-darwin, and home-manager configuration.",
      favicon: "/favicon.ico",
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/isabelroses/dotfiles",
        },
      ],
      plugins: [starlightCatppuccin({
        dark: { flavor: "mocha", accent: "sapphire" },
        light: { flavor: "latte", accent: "sapphire" },
      })],
      customCss: ["./src/styles/custom.css"],
      editLink: {
        baseUrl: "https://github.com/isabelroses/dotfiles/edit/main/docs/",
      },
      sidebar: [
        { label: "Introduction", slug: "introduction" },
        {
          label: "Design",
          autogenerate: { directory: "design" },
        },
        {
          label: "Guides",
          autogenerate: { directory: "guides" },
        },
        {
          label: "Lib",
          autogenerate: { directory: "lib" },
        },
        {
          label: "Modules options",
          autogenerate: { directory: "options" },
        },
      ],
    }),
  ],
});
