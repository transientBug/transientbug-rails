module.exports = {
  plugins: [
    require("postcss-easy-import"),
    require("postcss-nested"),
    require("tailwindcss"),
    require("postcss-flexbugs-fixes"),
    require("postcss-preset-env")({
      autoprefixer: {
        flexbox: "no-2009"
      },
      stage: 3
    }),
    require("autoprefixer"),
  ]
}
