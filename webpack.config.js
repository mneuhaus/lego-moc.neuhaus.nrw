// webpack.config.js
const Encore = require('@symfony/webpack-encore');
const path = require('path');

process.noDeprecation = true;

Encore
.disableSingleRuntimeChunk()
.setOutputPath('build')
.setPublicPath('/build')
//.cleanupOutputBeforeBuild()
.enableBuildNotifications()
.configureBabel(function (babelConfig) {
  babelConfig.presets[0][1].debug = true;
  babelConfig.plugins.push('@babel/plugin-proposal-class-properties');

  const preset = babelConfig.presets.find(([name]) => name === '@babel/preset-env');
  if (preset !== undefined) {
    preset[1].useBuiltIns = 'usage';
    preset[1].corejs = '3.0.0';
    preset[1].debug = false;
  }
})
.enableVueLoader()
.enableStylusLoader()
.addEntry('main', [
  './src/main.js',
  './src/main.css'
]);

// export the final configuration
var config = Encore.getWebpackConfig();
module.exports = config;
