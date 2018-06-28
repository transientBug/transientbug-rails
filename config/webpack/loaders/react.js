module.exports = {
  test: /\.(js|jsx)?(\.erb)?$/,
  exclude: /node_modules/,
  loader: 'babel-loader',
  options: {
      presets: ["env", "react"],
      plugins: ["transform-class-properties"]
  }
}
