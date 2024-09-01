const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
      './js/app.js': ['./js/app.js'].concat(glob.sync('./vendor/**/*.js'))
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  resolve: {
     modules: [path.join(__dirname, "src"), "node_modules"],
     extensions: [".js", ".elm", ".scss", ".png", ".svg"]
  },
  module: {
    rules: [
      {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
              loader: 'babel-loader'
          }
      },
      {
          test: /\.css$/,
          use: [MiniCssExtractPlugin.loader, 'css-loader']
      },
      { 
          test: /\.static$/,
          use: {
              loader: 'babel-loader'
          }
      },
      {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],                                                                                                                                                                    
          use: [ 
             { loader: 'elm-hot-webpack-loader'
             },
             { loader: 'elm-webpack-loader',
                 options: {
                    debug: true
                 }
             }
          ]
        
      },
      {
          test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader: "file-loader"
      },
      {
          test: /\.(jpe?g|png|gif|svg)$/i,
          exclude: [/elm-stuff/, /node_modules/],
          use : [
              {loader: "file-loader"}
          ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.css' }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
  ]
});
