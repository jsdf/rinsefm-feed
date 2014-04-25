http = require 'http'
path = require 'path'

express = require 'express'
level = require 'level'
browserify = require 'browserify-middleware'
moment = require 'moment'

app = express()
db = level './store', valueEncoding: 'json'
config = require('./config.json')

config.maxAgeDynamic = moment.duration(1, 'hours').asSeconds()
config.maxAgeStatic = moment.duration(24, 'hours').asSeconds()

# all environments
app.set 'port', process.env.PORT or config.port or 3000
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'hjs'

app.use require('static-favicon')()
app.use require('morgan')('dev')
app.use require('body-parser')()
app.use require('method-override')()

routes = require('./routes')(app, db, config)
app.get '/', routes.builder
app.get '/shows', routes.shows
app.get '/podcast', routes.podcast
app.get '/update', routes.update
app.get '/list', routes.list

app.get '/javascripts/client.js', browserify './client/client.coffee',
  extensions: ['.js','.coffee']
  transform: ['coffee-reactify']

app.use require('less-middleware')(
  path.join(__dirname, 'public'),
  {
    once: app.get 'env' is 'production'
  },
  {},
  {
    compress: app.get 'env' is 'production'
    sourceMap: app.get 'env' is 'development'
  }
)
app.use require('serve-static')(path.join(__dirname, 'public'), maxAge: config.maxAgeStatic)
app.use require('errorhandler')() if app.get 'env' is 'development'
  
app.listen app.get('port'), ->
  console.log "Express #{app.get 'env'} server listening on port #{app.get 'port'}"
