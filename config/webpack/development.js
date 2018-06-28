process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

environment.devTool = "sourcemap"

module.exports = environment.toWebpackConfig()
