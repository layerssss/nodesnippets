
fs=require('fs')
path=require('path')
url=require 'url'



isEditor=(path)->




exports.register=(app)->
  app.get '*',(req,res,next)->
    req.address=req.headers['x-forwarded-for']||req.connection.remoteAddress
    await fs.readFile path.basename(req.params[0])+'/.editors','utf8',defer err,editors
    req.isEditor=err?||!editors.match(addr)
    next()

  app.get "*/",(req,res,next)->
    req.curPath=app.cfg.root+req.params[0];
    if !fs.existsSync(req.curPath)
      return next()
    if fs.statSync(req.curPath).isFile()
      res.render 'view',
        title: 'View - '+req.params[0]
    if fs.statSync(req.curPath).isDirectory()
      await fs.readdir req.curPath,defer(error,files)
      await fs.readFile req.curPath+'/.private','utf8',defer err,priv
      files=files.map (file)->
        if priv?
          for line in priv.split '\n'
            if file.match(line)&&file.match(line)[0].length==file.length
              return null
        try
          stat=fs.statSync req.curPath+'/'+file
        catch e
          return null
        obj=stat
        obj.filename=file
        obj.icon='icon-folder-2'
        obj.link=file

        if obj.isFile()
          obj.icon='icon-paper'
          ext=path.extname file
          if ext in ['.yaml','.xml']
            obj.icon='icon-file-xml'
            obj.link+='/'
          if ext in ['.html','.htm']
            obj.icon='icon-html5-2'
          if ext in ['.gz','.tar','.rar','.zip','.msi','.pkg','.exe','.deb']
            obj.icon='icon-file-zip'
          if ext in ['.sass','.css','.less','.coffee','.iced','.js']
            obj.icon='icon-file-css'
            obj.link+='/'
          if ext in ['.md','.txt','.log','.config','.php','.rb','.jade','.aspx','.java','.cs','.c']
            obj.link+='/'
        else
          obj.link+='/'
        obj
      files=files.filter (file)->file!=null&&file.filename[0]!='.'&&!file.filename.match /~$/

      files=files.sort (a,b)->
        if a.isFile()&&b.isDirectory()
          return 1
        if a.isDirectory&&b.isFile()
          return -1
        if a.filename<b.filename
          return -1
        if a.filename==b.filename
          return 0
        return 1
      res.render 'index',
        title: 'Browse - '+req.params[0],
        files:files





  edit=(req,res)->
    p=app.cfg.root+'/'+req.params[0]
    p=path.dirname p
    res.setHeader 'Content-Type','text/plain; charset=utf-8'
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
