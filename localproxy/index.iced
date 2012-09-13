http = require('http')
httpProxy = require('http-proxy')
fs=require 'fs'
nurl= require 'url'
yaml=require 'js-yaml'
cfg=yaml.load fs.readFileSync process.argv[2],'utf8'
server=httpProxy.createServer (req, res, proxy)->
	if req.url.match /\?localproxy-reset/
		cfg=yaml.load fs.readFileSync process.argv[2],'utf8'
	localPort=req.url.match /\/([\d]+)\/(.+)/
	remotePort=req.url.match /\/([\d\.]+)\/([\d]+)\/(.+)/
	[host,port]=[cfg.defaultHost,cfg.defaultPort]
	path=cfg.defaultPath+req.url.substring 1
	if localPort&&!localPort.index
		[dummy,port,path]=localPort
		path=cfg.defaultPath+path
	if remotePort&&!remotePort.index
		[dummy,host,port,path]=remotePort
		path=cfg.defaultPath+path
	for config in cfg.hosts
		matched=req.url.match "/#{config.alias}/(.*)"
		if matched
			[host,port]=[cfg.defaultHost,cfg.defaultPort]
			path=cfg.defaultPath+matched[1]
			if config.host? then host=config.host
			if config.port? then port=config.port
			if config.path? then path=config.path+path
	path=path||'/'
	console.log "#{host} #{port} #{path}"
	req.url=path
	
	proxy.proxyRequest req, res,
		host: host
		port: port
server.listen 80