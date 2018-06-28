const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.loaders.append('eslint', require('./loaders/eslint'))

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    _: 'lodash',
    React: 'react',
    ReactDOM: 'react-dom'
  })
)

module.exports = environment
