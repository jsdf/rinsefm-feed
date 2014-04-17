http = require 'http'
path = require 'path'

express = require 'express'
level = require 'level'

app = express()
db = level './store', valueEncoding: 'json'

# all environments
app.set 'port', process.env.PORT or 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'hjs'
app.use express.favicon()
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use require('less-middleware')(path.join(__dirname, 'public'))
app.use express.static path.join(__dirname, 'public')

# development only
if app.get 'env' is 'development' then app.use express.errorHandler()

routes = require('./routes')(app, db)
app.get '/', routes.list
app.get '/podcast.xml', routes.podcast
app.get '/update', routes.update

http.createServer(app)
  .listen app.get('port'), ->
    console.log "Express server listening on port #{app.get('port')}"
