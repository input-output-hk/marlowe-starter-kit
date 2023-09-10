const path = require('path')

module.exports = {
  entry           : './src/controller.js'
, mode            : 'production'
, output          : {
    filename      : 'controller.js'
  , path          : path.resolve(__dirname, '.')
  , libraryTarget : "var"
  , library       : "Controller"
  },
  devServer: {
    static: ".",
    allowedHosts: "all",
    host: "0.0.0.0",
    port: 8080,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
      "Access-Control-Allow-Headers": "X-Requested-With, content-type, Authorization"
    },
    https: {
      key: 'key.pem',
      cert: 'cert.pem'
    },
    client: {
      overlay: false,
    }
  }
}
