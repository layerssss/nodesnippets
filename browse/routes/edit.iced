exports.edit=(req,res)->
	fs=require('fs')
	path=require('path')
	nurl=require 'url'
	cp=require 'child_process'
	root=path.dirname(path.dirname(path.dirname(__dirname)))+'/'
	p=root+req.params[0]
	p=path.dirname p
	res.setHeader 'Content-Type','text/plain; charset=utf-8'
	addr=req.headers['x-forwarded-for']||req.connection.remoteAddress
	await fs.readFile p+'/.editors','utf-8',defer err,editors
	if err
		res.statusCode=403
		res.write 'this is a readonly file.'
		res.end()
		return 
	fname=path.basename(req.params[0])
	editor=null
	es=''
	for line in editors.split '\n'
		line=line.match /^[\t ]*([^\t ]+)[\t ]+([^\t \r\n]+)/
		if line?
			matching=fname.match new RegExp line[1]
			if matching?&&matching[0].length==fname.length
				if addr==line[2]
					editor=matching
				else
					es+=line[2]+';'
	if !editor?
		res.statusCode=403
		res.write 'you ('+addr+') are not allowed to edit this file. only "'+es+'" are allowed.'
		res.end()
		return 
	try
		p+='/'+path.basename(req.params[0])
		if req.body&&req.body.content
			fs.writeFileSync p,req.body.content,'utf8'
			if err
				throw err
	catch e
		res.statusCode=500
		res.write String e
		res.end()
	res.end()