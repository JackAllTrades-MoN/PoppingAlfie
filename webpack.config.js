module.exports = {
    mode: "development",
    entry: __dirname + "/_build/default/bin/cpop.bc.js",
    output: {
      path: __dirname +'/dist',
      filename: 'bundle.js'
    },
    resolve: {
        fallback: {
            fs: false,
            tty: false,
            child_process: false,
            constants: false,
        }
    },
    module: {},
    devServer: {
        open: true,
        static: [
            { directory: __dirname },
            { directory: __dirname + '/static' },
        ],
    }
  };
  