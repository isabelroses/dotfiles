import { execAsync, writeFile } from 'resource:///com/github/Aylur/ags/utils.js';

const generated = str => `// THIS FILE IS GENERATED
${str}`;

const scss = t => `$theme: '${t.color_scheme}';

$red: ${t.red};
$green: ${t.green};
$yellow: ${t.yellow};
$blue: ${t.blue};
$magenta: ${t.magenta};
$teal: ${t.teal};
$orange: ${t.orange};

$bg_color: ${t.bg_color};
$fg_color: ${t.fg_color};
$hover_fg: ${t.hover_fg};

$wm_gaps: ${t.wm_gaps}px;
$radii: ${t.radii}px;
$spacing: ${t.spacing}px;

$accent: ${t.accent};
$accent_fg: ${t.accent_fg};

$hover: transparentize(${t.widget_bg}, ${Math.max((t.widget_opacity * 0.90) / 100, 0)});
$widget_bg: transparentize(${t.widget_bg}, ${t.widget_opacity / 100});
$active_gradient: linear-gradient(${t.active_gradient});

$border_color: transparentize(${t.border_color}, ${t.border_opacity / 100});
$border_width: ${t.border_width}px;
$border: $border_width solid $border_color;

$shadow: ${t.shadow};
$text_shadow: 2px 2px 2px $shadow;
$icon_shadow: 2px 2px $shadow;

$popover_radius: ${t.radii * 1.7}px;
$popover_border_color: transparentize(${t.border_color}, ${Math.max((t.border_opacity - 1) / 100, 0)});
$popover_padding: ${t.spacing * 1.8}px;
$drop_shadow: ${t.drop_shadow};

$transition: ${t.transition}ms;

$font_size: 16px;
$font: 'Ubuntu Nerd Font';
$mono_font: 'Mononoki Nerd Font', monospace;
$wallpaper_fg: white;
$shader_fg: white;

$screen_corners: ${t.bar_style === 'normal' && t.screen_corners};
$bar_style: ${t.bar_style};
$layout: ${t.layout};`;

export async function setupScss(theme) {
    const path = ags.App.configDir;
    try {
        await writeFile(generated(scss(theme)), `${path}/scss/generated.scss`);
        await execAsync(['sassc', `${path}/scss/main.scss`, `${path}/style.css`]);
        ags.App.resetCss();
        ags.App.applyCss(`${path}/style.css`);
    } catch (error) {
        logError(error);
    }
}
