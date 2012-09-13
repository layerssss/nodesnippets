exports.makeresult=(req,res)->
	fs=require('fs')
	path=require('path')
	cp=require 'child_process'
	root=path.dirname(path.dirname(path.dirname(__dirname)))+'/'
	path=root+req.params[0]
	target=req.params[1]
	now=Number(new Date())

	if !req.app.makeversion?
		req.app.makeversion={}
	if !req.app.making?
		req.app.making={}


	while req.app.making[path+target]?
		await setTimeout defer(),110

	console.log 'start'
	req.app.making[path+target]={}
	await cp.exec "make #{target}",{cwd:path},defer err,stdout,stderr
	stdout+=stderr
	delete req.app.making[path+target]
	console.log 'end'

	console.log stdout
	res.setHeader 'Content-Type','text/plain; charset=utf-8'
	if err
		res.statusCode=500
		res.write stdout
	else
		if stdout.indexOf('make:')!=0
			req.app.makeversion[path+target]=now
			console.log 'version:'+now
			console.log 'end'
		if req.app.makeversion[path+target]?
			res.write String(req.app.makeversion[path+target])
		else
			res.write '0'
	res.end()