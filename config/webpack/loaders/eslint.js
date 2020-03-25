module.exports = {
  test: /\.(j|t)(s|sx)?(\.erb)?$/,
  exclude: /node_modules/,
  loader: 'eslint-loader',
  enforce: "pre",
  options: {
    failOnError: false
  }
}
