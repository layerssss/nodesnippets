express = require("express")
path = require("path")
app = express();

if process.argv.length!=4
  console.error 'Usage: iced browse PORT PATH'
  process.exit(1)
  return

app.cfg=
  port: Number(process.argv[2])
  root: path.resolve(process.argv[3]).replace(/\/$/,'')

app.configure ->
  app.locals.rootPath = process.env.ROOTPATH||'/'
  app.set "views", __dirname
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.compress
    filter: (req, res) ->
      ctype = res.getHeader("Content-Type")
      ctype? and ctype.match(/json|text|javascript/)?
  app.use express.static(app.cfg.root)
  app.use express.static(__dirname+path.sep+'assets')

app.configure "development", ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure "production", ->
  app.use express.errorHandler()

require("./controllers").register(app)


app.get "*.jsonp/[^.]+", (req, res, next) ->
  res.setHeader "Content-Type", "text/javascript; charset=utf8"
  next()

app.get "*.json/[^.]+", (req, res, next) ->
  res.setHeader "Content-Type", "text/json; charset=utf8"
  next()

app.listen app.cfg.port, ->
  console.log "Express server listening"
  console.log app.cfg