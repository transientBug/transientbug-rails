module.exports = {
  parser: "babel-eslint",
  extends: [
    "plugin:prettier/recommended",
    "prettier/flowtype",
    "prettier/react",
    "prettier/standard"
  ],

  plugins: ["prettier"],

  env: {
    browser: true,
  },

  globals: {
    React: true,
    ReactDOM: true,
    _: true,
    Rails: true,
  },

  rules: {
  }
}
