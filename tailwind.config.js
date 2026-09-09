/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./nuxt.config.{js,ts}",
    "./app.vue",
    "./components/**/*.{vue,js,ts}",
  ],
  theme: {
    extend: {
      colors: {
        // The handset body: a warm olive-black, not a neutral near-black.
        hull: {
          DEFAULT: "#16170F",
          raised: "#1F2116",
        },
        rule: "#33362A",
        // Backlit LCD: yellow-green ground, dark olive segments.
        lcd: {
          DEFAULT: "#C6D96B",
          bright: "#D8E88C",
          ink: "#2B3312",
          dim: "#5C6636",
          off: "#3A4021",
        },
        paper: "#EAE9DE",
        muted: "#8B8E7C",
        // Reserved for errors only, so it never competes with the LCD green.
        signal: "#E8834A",
      },
      fontFamily: {
        display: ["Archivo", "ui-sans-serif", "system-ui", "sans-serif"],
        mono: ["DM Mono", "ui-monospace", "SFMono-Regular", "monospace"],
      },
    },
  },
  plugins: [],
};
