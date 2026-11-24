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
        // pink, to match izshell's accent
        dark: { flavor: "mocha", accent: "pink" },
        light: { flavor: "latte", accent: "pink" },
      })],
      customCss: ["./src/styles/custom.css"],
      components: {
        Footer: "./src/components/Footer.astro",
      },
      editLink: {
        baseUrl: "https://github.com/isabelroses/dotfiles/edit/main/docs/",
      },
      sidebar: [
        { label: "Introduction", slug: "introduction" },
        {
          label: "Design",
          items: [{ autogenerate: { directory: "design" } }],
        },
        {
          label: "Guides",
          items: [{ autogenerate: { directory: "guides" } }],
        },
        {
          label: "Fleet",
          items: [
            { label: "Services", slug: "services" },
            {
              label: "Hosts",
              items: [{ autogenerate: { directory: "hosts" } }],
            },
          ],
        },
        {
          label: "Lib",
          items: [{ autogenerate: { directory: "lib" } }],
        },
        {
          label: "Modules options",
          items: [{ autogenerate: { directory: "options" } }],
        },
      ],
    }),
  ],
});
