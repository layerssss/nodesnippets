mysql = require 'mysql'
url = require 'url'
{
	Name
	Helpers
  Internet
} = require 'faker-zh-cn'
classifications = require '../lib/classifications'
metrics = require '../lib/metrics'

{
  MYSQL_URI
} = process.env
MYSQL_URI?= 'mysql://localhost/wanalytic'

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

await db_query "delete from sites", defer e
throw e if e
await db_query "delete from stats", defer e
throw e if e

await db_query "insert into sites set ?", name: Internet.domainWord(), defer e, results
throw e if e
sid = results.insertId


cur = Date.now()
for i in [0 .. 5 * 24]
  cur -= 3600 * 1000

  for key, cgroup of classifications
    for c in cgroup
      for type in c._population
        for key, mgroup of metrics
          for m in mgroup
            await db_query "insert into stats set ?", site_id: sid, type: type, metric: m.id, classification: c.id, time: cur, value: Helpers.randomNumber(100), defer e
            throw e if e




conn.destroy() for conn in db_connectionPool._allConnections