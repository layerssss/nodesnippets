exports.make=(req,res)->
	fs=require('fs')
	path=require('path')
	cp=require 'child_process'
	root=path.dirname(path.dirname(path.dirname(__dirname)))+'/'
	path=root+req.params[0]
	arr=req.params[0].split('/')
	link=''
	breadcrumb=[{text:'Browse',link:'/'}]
	for i in [0..arr.length-1]
		if arr[i]!=''
			link+='/'+arr[i]
			breadcrumb[breadcrumb.length]=
				text:arr[i]
				link:link
	res.render 'make',
		title: 'MakeStatus - '+req.params[0]
		dir:req.params[0]
		breadcrumb:breadcrumb
		target:req.params[1]
		nav:
			make:'active'