module.exports = {
  parser: "babel-eslint",
  extends: [
    "plugin:prettier/recommended",
    "prettier/react",
    "prettier/standard"
  ],

  plugins: ["prettier"],

  env: {
    browser: true,
  },

  globals: {
    Rails: true,
  },

  rules: { }
}
