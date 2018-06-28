module.exports = {
  test: /\.(js|jsx)?(\.erb)?$/,
  exclude: /node_modules/,
  loader: 'eslint-loader',
  enforce: "pre",
  options: {
    failOnError: true
  }
}
