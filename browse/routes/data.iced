exports.data=(req,res,next)->
	nurl=require 'url'
	fs=require 'fs'
	path=require 'path'
	url=nurl.parse req.url
	if !url.query
		url.query=''
	url.pathname=url.pathname.replace /_/g,'.'
	for e in ['.json','.jsonp','.yaml','.mangled.yaml']
		await fs.exists path.dirname(path.dirname(path.dirname(__dirname)))+url.pathname+e,defer exists
		if exists
			ext=e
	if url.query.match( 'dataType=json') or (req.headers['accept']&&req.headers['accept'].match /json/)
		type='json'
	if url.query.match( 'dataType=jsonp') or (req.headers['accept']&&req.headers['accept'].trim().match /^text\/javascript/)
		type='jsonp'
	if url.query.match( 'dataType=yaml') or (req.headers['accept']&&req.headers['accept'].match /yaml/)
		type='yaml'
	if !type? || !ext? 
		return next()
	err={}
	while err?
		await fs.readFile path.dirname(path.dirname(path.dirname(__dirname)))+url.pathname+ext,'utf8',defer err,data
	try
		if ext=='.yaml'||ext=='.mangled.yaml'
			data=require('js-yaml').load require('../../unmangle/unmangle').unmangle(data,url.query)
		if ext=='.json'	
			data=JSON.parse data
		if ext=='.jsonp'
			data=data.match(/[^\(]+\((.+)\);[\r\n\s\t]*$/)[1]
			eval 'data='+data+';'
			if String(data.statusCode)=='200'
				data=data.data
			else 
				throw new Error 'status:'+d.statusCode
	catch e
		res.write String e
		res.end()
		res.statusCode==500
		return
	if type=='json'
		res.setHeader 'Content-Type','text/json;charset=utf-8'
		res.write JSON.stringify data
		
	if type=='jsonp'
		res.setHeader 'Content-Type','text/javascript;charset=utf-8'
		res.write (url.query.match(/callback=([^&]*)/)||['','dSet'])[1]
		res.write '({"statusCode":200,"data":'
		res.write JSON.stringify data
		res.write '});'
		
	if type=='yaml'
		res.setHeader 'Content-Type','text/yaml;charset=utf-8'
		res.wrte 'not support'
	res.end()