module.exports = {
  parser: "babel-eslint",
  extends: "airbnb",

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
    // Doesn't seem to play nice with webpacker setup
    "import/no-unresolved": "off",

    // Match ruby style, don't use semicolons ever and double quote strings
    quotes: ["error", "double"],
    semi: ["error", "never"],

    // Spaces in [] and ${} for readability
    "computed-property-spacing": [1, "always"],
    "template-curly-spacing": [1, "always"],

    // god i hate extra commas
    "comma-dangle": "off",

    // Let me two line, no curly bracket, if statement
    "nonblock-statement-body-position": ["error", "below"],
    "curly": ["error", "multi-or-nest"],

    //
    "object-curly-newline": [2, { "consistent": true }],

    // Let me name unused variables with an underscore because sometimes you
    // need them
    "no-unused-vars": [2, { args: "all", argsIgnorePattern: "^_" }],

    // Spaces in react jsx {}
    "react/jsx-curly-spacing": [1, "always"],

    // It wants me to destructure EVERYTHING and sometimes its ugly
    "react/destructuring-assignment": "off",

    // Lets not check prop types just yet, m'kay?
    "react/prop-types": "off"
  }
}
