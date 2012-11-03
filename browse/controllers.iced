
fs=require('fs')
path=require('path')
url=require 'url'
jsyaml=require 'js-yaml'


defaultConfig=
  users:[]

exports.register=(app)->
  await fs.readFile app.cfg.root+'/.browse.config.yaml','utf8',defer err,config
  config= if err? then defaultConfig else jsyaml.load config


  app.all "*",(req,res,next)->
    res.locals.path=req.path.substring 0,req.path.lastIndexOf('/')+1
    res.locals.resolved=app.cfg.root+ res.locals.path.replace /\/$/,''
    res.locals.address=req.headers['x-forwarded-for']||req.connection.remoteAddress




    authorization=req.headers['authorization']
    if authorization?
      authorization=(new Buffer(authorization.replace(/Basic /,''), 'base64').toString('utf8')).split ':'
      res.locals.user=config.users.filter((u)->u.username==authorization[0]&&u.password==authorization[1])[0]
      if res.locals.user?
        res.setHeader 'WWW-Authenticate','Basic realm="Browse"'



    p=res.locals.resolved
    res.locals.isEditor=false
    while p.length>=app.cfg.root.length&&!res.locals.isEditor
      await fs.readFile p+'/.editors','utf8',defer err,editors
      res.locals.isEditor=(!err?&&(editors.match(res.locals.address)||(res.locals.user?&&editors.match(res.locals.user.username))))#||res.locals.address=='127.0.0.1'
      p=path.dirname p
    next()



  app.all "*/",(req,res,next)->
    res.locals.title="Browse - #{res.locals.path}"
    if !fs.existsSync(res.locals.resolved)
      return next()
    if fs.statSync(res.locals.resolved).isFile()
      res.render 'view'
    if fs.statSync(res.locals.resolved).isDirectory()
      await fs.readdir res.locals.resolved,defer(error,files)
      await fs.readFile res.locals.resolved+'/.privates','utf8',defer err,privates
      files2=[]
      for file in files
        # if privates?
        #   isPrivate=false
        #   for line in privates.split '\n'
        #     if file.match(line)&&file.match(line)[0].length==file.length
        #       isPrivate=true
        #   if isPrivate
        #     continue
        stat=fs.statSync res.locals.resolved+'/'+file
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
          if ext in ['.sass','.css','.less','.coffee','.iced','.js','.json']
            obj.icon='icon-file-css'
            obj.link+='/'
          if ext in ['.md','.txt','.log','.config','.php','.rb','.jade','.aspx','.java','.cs','.c']
            obj.link+='/'
        else
          await fs.readFile res.locals.resolved+'/'+file+'/.special','utf8',defer err,obj.special

          if obj.special?
            obj.special=JSON.parse obj.special
          obj.link+='/'
        files2.push obj

      files=files2.filter (file)->file!=null&&file.filename[0]!='.'&&!file.filename.match /~$/




      # files=files.sort (a,b)->
      #   if a.isFile()&&b.isDirectory()
      #     return 1
      #   if a.isDirectory&&b.isFile()
      #     return -1
      #   if a.filename<b.filename
      #     return -1
      #   if a.filename==b.filename
      #     return 0
      #   return 1
      res.render 'index',
        files:files.filter (f)->!f.special?
        specials:files.filter (f)->f.special?


  app.post '*/upload',(req,res,next)->
    if !res.locals.isEditor
      res.statusCode=403
      res.write "Permission denied."
      return res.end()
    if req.files.file.name.length
      fs.createReadStream(req.files.file.path).pipe(fs.createWriteStream(res.locals.resolved+'/'+ req.files.file.name))
    res.write "<script>location.href='#{req.params[0]||'/'}';</script>"
    res.end()


  app.all '*/login',(req,res,next)->
    if res.locals.user?
      res.statusCode=302
      res.setHeader 'Location',req.params[0]||'/'
    else
      res.statusCode=401
      res.setHeader 'WWW-Authenticate','Basic realm="Browse"'
      res.write "<script>location.href='#{req.params[0]||'/'}';</script>"
    res.end()

  app.all '*/logout',(req,res,next)->
    res.statusCode=401
    res.write "<script>location.href='#{req.params[0]||'/'}';</script>"
    res.end()

  app.all "*/edit", (req,res)->
    if !res.locals.isEditor
      res.statusCode=403
      res.write "Permission denied."
      return res.end()
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
