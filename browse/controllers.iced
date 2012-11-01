
fs=require('fs')
path=require('path')
url=require 'url'





exports.register=(app)->
  app.get "*/",(req,res,next)->
    curPath=app.cfg.root+req.params[0];
    console.log(curPath);
    arr=req.params[0].split('/');
    link='';
    await fs.readdir curPath,defer(error,files)
    if error?
      console.error error
      return next()
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
      dir:req.params[0]


  app.get "*/",(req,res,next)->
    folder=app.cfg.root+'/'+req.params[0]
    if !fs.existsSync(folder)||!fs.statSync(folder).isFile()
      return next()
    arr=req.params[0].split('/')
    link=''
    res.render 'view',
      title: 'View - '+req.params[0]
      dir:req.params[0]




  edit=(req,res)->
    p=app.cfg.root+'/'+req.params[0]
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
  app.get "*/edit", edit
  app.post "*/edit", edit
