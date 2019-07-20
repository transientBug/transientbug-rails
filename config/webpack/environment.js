const { environment } = require('@rails/webpacker')
const typescript =  require('./loaders/typescript')
const eslint = require('./loaders/eslint')

environment.loaders.prepend('typescript', typescript)
environment.loaders.append('eslint', eslint)

module.exports = environment
