{
  MYSQL_URI
  PORT
  NODE_ENV
} = process.env
NODE_ENV?= 'development'
PORT?= 3000
MYSQL_URI?= 'mysql://localhost/wanalytic'


express = require 'express'
url = require 'url'
querystring = require 'querystring'
path = require 'path'
stylus = require 'stylus'
nib = require 'nib'
fs = require 'fs'
os = require 'os'
moment = require 'moment'
moment.lang 'zh-cn'
mysql = require 'mysql'
_ = require 'underscore'

connectCoffeeScript = require 'connect-coffee-script'
expressUglify = require 'express-uglify'
{
  exec
} = require 'child_process'

_package = require './package.json'
classifications = require './lib/classifications'
metrics = require './lib/metrics'



MYSQL = url.parse MYSQL_URI
db_connectionPool = mysql.createPool
  host: MYSQL.host
  port: MYSQL.port
  database: MYSQL.pathname.substring 1
  user: MYSQL.auth?.split(':')[0]
  password: MYSQL.auth?.split(':')[1]

db_query = (sql, params..., cb)->

  await db_connectionPool.getConnection defer e, conn
  return cb e if e
  await conn.query sql, params, defer e, rows
  conn.end()
  return cb e if e
  cb null, rows

await db_query "select * from sites", defer e, sites
throw e if e
console.error "警告： 没有配置站点" unless sites.length

app = new express()
if NODE_ENV == 'development'
  app.locals.pretty = true
app.locals.version = _package.version
app.set 'view engine', 'jade'
app.set 'views', path.join __dirname, 'views'

app.use '/scripts', connectCoffeeScript
  src: path.join __dirname, 'src'
  dest: path.join __dirname, 'public'
app.use '/scripts', expressUglify.middleware
  src: path.join __dirname, 'public'
  logLevel: 'warning'

app.use '/style', stylus.middleware
  src: path.join __dirname, 'src'
  dest: path.join __dirname, 'public'
  compile: (str, path)-> stylus(str).set('filename', path).set('comprss', false).use nib()
app.use '/style', express.static path.join __dirname, 'public'

app.use express.static path.join __dirname, 'src', 'raw'
app.use '/lib', express.static path.join __dirname, 'bower_components'
app.use express.cookieParser()
app.use express.session
  secret: process.env.SECRET||'SECRET'
  cookie:
    path: '/'
    httpOnly: true
    maxAge: 365 * 24 * 60 * 60 * 1000

app.locals.classifications_groups = classifications
app.locals.metrics_groups = metrics

app.locals.classifications_all = classifications_all = []
for key, group of classifications
  for classification in group
    classification.group = key
    classifications_all.push classification

app.locals.metrics_all = metrics_all = []
for key, group of metrics
  for metric in group
    metric.group = key
    metrics_all.push metric




app.all '*', (rq, rs, cb)->
  rs.locals.params = rq.params
  
  cb()

app.param 'sid', (rq, rs, cb, sid)->
  await db_query "select * from sites where id=?", sid, defer e, sites
  return cb e if e
  rs.locals.site = sites[0]
  return cb 404 unless rs.locals.site
  cb()


app.get '/', (rq, rs, cb)->
  await db_query "select * from sites", defer e, sites
  return cb e if e
  return cb new Error '没有配置可以显示的站点' unless sites.length
  rs.redirect "./site#{sites[0].id}/"

app.get '/site:sid/', (rq, rs, cb)->
  rs.redirect './stats/'




app.get '/site:sid/stats/', (rq, rs, cb)->
  rs.locals.query = rq.query

  rq.query.cid?= classifications_all[0].id
  rs.locals.cid = Number rq.query.cid
  [rs.locals.classification] = classifications_all.filter (c)-> c.id is rs.locals.cid
  return cb 404 unless rs.locals.classification

  rq.query.mids?= metrics_all.slice(0, 5).map((m)->m.id).join('-')
  rs.locals.mids = rq.query.mids.split('-').map (mid)-> Number mid
  rs.locals.metrics = metrics_all.filter (m)-> m.id in rs.locals.mids

  rq.query.m1id?= rs.locals.mids[0]
  rs.locals.m1id = Number rq.query.m1id
  [rs.locals.metric1] = metrics_all.filter (c)-> c.id is rs.locals.m1id
  return cb 404 unless rs.locals.metric1

  rq.query.m2id?= rs.locals.mids[1]
  rs.locals.m2id = Number rq.query.m2id
  [rs.locals.metric2] = metrics_all.filter (c)-> c.id is rs.locals.m2id
  return cb 404 unless rs.locals.metric2

  rq.query.g?= 0
  rs.locals.g = Number rq.query.g
  return cb 404 unless rs.locals.g in [0, 1, 2, 3, 4] 

  rq.query.ends?= Date.now()
  rs.locals.ends = Number rq.query.ends
  
  rq.query.starts?= rq.query.ends - 1000 * 3600 * 24 * 30
  rs.locals.starts = Number rq.query.starts

  rs.locals.getStatsUrl = (params)-> 
    obj = {}
    obj[k] = v for k, v of rs.locals.query
    obj[k] = v for k, v of params
    "/site#{rs.locals.site.id}/stats/?#{querystring.stringify obj}"


  await db_query "select * from stats where classification = ? and site_id = ? and time < ? and time > ?", rs.locals.cid, rs.locals.site.id, rs.locals.ends, rs.locals.starts, defer e, stats
  return cb e if e

  INTERVAL = 1000 * 3600
  types = {}
  rs.locals.all = 
    name: '(全部)'
    type: all =
      times: Array Math.floor (rs.locals.ends - rs.locals.starts) / INTERVAL
      sums: Array rs.locals.mids.length
  for stat in stats
    type = types[stat.type]?= 
      times: Array Math.floor (rs.locals.ends - rs.locals.starts) / INTERVAL
      sums: Array rs.locals.mids.length
    i = rs.locals.mids.indexOf stat.metric
    if i != -1
      type.sums[i] ?= 0
      type.sums[i] += stat.value
      all.sums[i] ?= 0
      all.sums[i] += stat.value

    time = type.times[Math.floor (stat.time - rs.locals.starts) / INTERVAL] ?= [0, 0]
    timeall = all.times[Math.floor (stat.time - rs.locals.starts) / INTERVAL] ?= [0, 0]
    if stat.metric == rs.locals.m1id
      time[0] += stat.value
      timeall[0] += stat.value
    if stat.metric == rs.locals.m2id
      time[1] += stat.value
      timeall[1] += stat.value

  rs.locals.types = []
  for name, type of types
    rs.locals.types.push
      name: name
      type: type



  rs.locals.types.splice 5


  rs.locals.rest =
    name: '(其它)'
    type:
      times: all.times.map (time, t)->
        [
          rs.locals.types.reduce ((s, type)-> s - type.type.times[t][0]), time[0]
          rs.locals.types.reduce ((s, type)-> s - type.type.times[t][0]), time[1]
        ]
      sums: all.sums.map (sum, m)->
        rs.locals.types.reduce ((s, type)-> s - type.type.sums[m]), sum









  rs.render 'stats'


app.get '*', (rq, rs, cb)->
  cb 404

errors = 
  '404': '找不到页面'
  '500': '服务器错误'
  '403': '没有权限'

app.use (err, rq, rs, cb)->
  if err.constructor is Number && message = errors[String err]
      rs.statusCode = err
      err = new Error message
  else
    rs.statusCode = 500
  rs.render 'error',
    message: err.message||"未知错误 (#{String err})"


  




await server = app.listen (Number PORT), defer e
throw e if e
console.log server.address()