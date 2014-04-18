http = require 'http'
path = require 'path'

express = require 'express'
level = require 'level'
browserify = require 'browserify-middleware'

app = express()
db = level './store', valueEncoding: 'json'

# all environments
app.set 'port', process.env.PORT or 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'hjs'

app.use require('static-favicon')()
app.use require('morgan')('dev')
app.use require('body-parser')()
app.use require('method-override')()

routes = require('./routes')(app, db)
app.get '/', routes.list
app.get '/podcast.xml', routes.podcast
app.get '/update', routes.update

app.get '/javascripts/client.js', browserify './client/client.coffee',
  extensions: ['.js','.coffee']
  transform: ['coffee-reactify']
  grep: /\.(?:js|coffee|ls)$/

app.use require('less-middleware')(path.join __dirname, 'public')
app.use require('serve-static')(path.join __dirname, 'public')
app.use require('errorhandler')() if app.get 'env' is 'development'
  
app.listen app.get('port'), ->
  console.log "Express #{app.get('env')} server listening on port #{app.get('port')}"
