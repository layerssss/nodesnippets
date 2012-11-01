exports.view=(req,res,next)->
	fs=require('fs')
	path=require('path')
	cp=require 'child_process'
	root=path.dirname(path.dirname(path.dirname(__dirname)))+'/'
	path=root+req.params[0]
	if !fs.existsSync(path)||!fs.statSync(path).isFile()
		return next()
	arr=req.params[0].split('/')
	link=''
	res.render 'view',
		title: 'View - '+req.params[0]
		dir:req.params[0]