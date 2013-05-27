express = require 'express'
routes = require './routes'
user = require './routes/user'
http = require 'http'
path = require 'path'

app = express()

# all environments
app.set 'port', process.env.PORT or 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'hjs'
app.use express.favicon()
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use require('less-middleware')(src: __dirname + '/public')
app.use express.static path.join(__dirname, 'public')

# development only
if app.get 'env' is 'development' then app.use express.errorHandler()

app.get '/', routes.index
app.get '/users', user.list

http.createServer(app).listen(app.get('port'), -> console.log('Express server listening on port ' + app.get('port')))