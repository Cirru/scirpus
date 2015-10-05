
var path = require('path')

module.exports = {
  entry: {
    main: [
      'webpack-dev-server/client?http://0.0.0.0:8080',
      'webpack/hot/dev-server',
      './src/main'
    ]
  },
  output: {
    path: 'build/',
    filename: '[name].js',
    publicPath: 'http://localhost:8080/build/'
  },
  resolve: {
    extensions: ['', '.js', '.cirru']
  },
  module: {
    loaders: [
      {test: /\.cirru$/, loader: 'cirru-script'},
      {test: /\.json$/, loader: 'json'},
      {test: /\.css$/, loader: 'style!css'},
    ],
    noParse: [
      path.resolve('./node_modules/babel-core/browser.js')
    ]
  },
  plugins: []
}
