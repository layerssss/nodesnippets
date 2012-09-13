exports.index = (req,res)->
	fs=require('fs');
	path=require('path')
	root=path.dirname(path.dirname(path.dirname(__dirname)));
	curPath=root+req.params[0];
	console.log(curPath);
	arr=req.params[0].split('/');
	link='';
	breadcrumb=[{
		text:'Browse',
		link:'/'
	}];
	for i in [0..arr.length-1]
		if arr[i]!=''
			link+='/'+arr[i]
			breadcrumb[breadcrumb.length]=
				text:arr[i]
				link:link
	await fs.readdir curPath,defer(error,files)
	if error?
		console.error error
		res.statsCode=404
		res.setHeader 'Content-Type','text/html'
		res.write "no.....it's not here anymore... <br/><br/><br/><br/><br/><a href=\"/\">!!!!!!!!!!!!TAKE ME BACK!!!!!!!!!!!!</a>"
		res.end()
		return
	await fs.readFile curPath+'/.private','utf8',defer err,priv
	files=files.map (file)->
		if priv?
			for line in priv.split '\n'
				if file.match(line)&&file.match(line)[0].length==file.length
					return null
		try
			stat=fs.statSync curPath+'/'+file
		catch e
			return null
		obj=
			stat:stat
			filename:file
			icon:'icon-folder-2'
		if stat.isFile()
			obj.icon='icon-paper'
			ext=path.extname file
			if ext in ['.yaml','.xml']
				obj.icon='icon-file-xml'
			if ext in ['.html','.htm']
				obj.icon='icon-html5-2'
			if ext in ['.gz','.tar','.rar','.zip','.msi','.pkg','.exe','.deb']
				obj.icon='icon-file-zip'
			if ext in ['.sass','.css','.less','.coffee','.iced','.js']
				obj.icon='icon-file-css'
		obj
	files=files.filter (file)->file!=null&&file.filename[0]!='.'&&!file.filename.match /~$/

	files=files.sort (a,b)->
		if a.filename<b.filename
			return -1
		if a.filename==b.filename
			return 0
		return 1
	res.render 'index',
		title: 'Browse - '+req.params[0],
		files:files.filter (file)->file.stat.isFile()
		folders:files.filter (file)->file.stat.isDirectory()
		dir:req.params[0],
		breadcrumb:breadcrumb
		nav:
			index:'active'
exports.makeresult=require('./makeresult').makeresult;
exports.make=require('./make').make;
exports.data=require('./data').data;
exports.edit=require('./edit').edit;
exports.view=require('./view').view;
exports.renderhtml=require('./renderhtml').renderhtml;