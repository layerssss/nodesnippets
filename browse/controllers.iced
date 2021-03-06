
fs=require('fs')
path=require('path')
url=require 'url'
jsyaml=require 'js-yaml'
showdown=require('showdown')

defaultConfig=
  users:[]

exports.register=(app)->
  converter=new showdown.converter()
  config=defaultConfig
  try
    config=jsyaml.load fs.readFileSync app.cfg.root+'/.browse.config.yaml','utf8'
  catch e
  console.log config
  app.all "*",(req,res,next)->
    res.locals.path=decodeURIComponent req.path.substring 0,req.path.lastIndexOf('/')+1
    res.locals.resolved=path.resolve app.cfg.root+ res.locals.path.replace(/\/$/,'')
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
      if p==path.dirname p
        break
      p=path.dirname p
    next()

  preciousKeys=['private','bigicon']
  propertyKeys=['icon','name']
  readmeFiles=['README','README.md','README.txt','README.markdown','Readme','Readme.md','Readme.txt','Readme.markdown']
  app.get "*/",(req,res,next)->
    
    res.locals.title="Browse - #{res.locals.path}"
    await fs.readdir res.locals.resolved,defer(error,files)
    if error?
      console.error error
      return next()
    precious={}
    for key in preciousKeys
      await fs.readFile res.locals.resolved+"#{path.sep}.#{key}s",'utf8',defer err,precious[key]
      if precious[key]?
        precious[key]=precious[key].split '\n'
      else
        precious[key]=[]
    files2=[]
    for file in files
      await fs.stat res.locals.resolved+path.sep+file,defer err,stat
      if err?
        stat=
          isFile:->false
      obj=stat
      obj.name=file
      obj.icon='icon-folder-2'
      obj.link=encodeURIComponent(file)

      if obj.isFile()
        if file in readmeFiles
          await fs.readFile res.locals.resolved+path.sep+file,'utf8',defer err,README
          if !err?
            res.locals.basename=file
            res.locals.markdown=converter.makeHtml README
        obj.icon='icon-paper'
        ext=path.extname file
        if ext in ['.yaml','.xml']
          obj.icon='icon-file-xml'
          obj.link="#{encodeURIComponent(file)}/"
        if ext in ['.html','.htm']
          obj.icon='icon-html5-2'
        if ext in ['.gz','.tar','.rar','.zip','.msi','.pkg','.exe','.deb']
          obj.icon='icon-file-zip'
        if ext in ['.sass','.css','.less','.coffee','.iced','.js','.json']
          obj.icon='icon-file-css'
          obj.link="#{encodeURIComponent(file)}.view"
        if ext in ['.txt','.log','.config','.php','.rb','.jade','.aspx','.java','.cs','.c']
          obj.link="#{encodeURIComponent(file)}.view"
        if ext in ['.md','.markdown'] or file.toLowerCase() in ['readme','readme.txt']
          obj.icon='icon-newspaper'
          obj.link="#{encodeURIComponent(file)}.markdown"
      else
        for k in propertyKeys
          await fs.readFile res.locals.resolved+path.sep+file+path.sep+".#{k}",'utf8',defer err,v
          if v?
            obj[k]=v
        obj.link+='/'


      for key,list of precious
        obj["is#{key}"]=false
        for line in list
          matching=file.match(new RegExp(line.trim()))
          if matching?&&matching[0].length==file.length
            obj["is#{key}"]=true


      files2.push obj

    files=files2.filter (file)->file!=null&&file.name[0]!='.'&&!file.name.match(/~$/)&&!file.isprivate

    files=files.sort (a,b)->
      if a.name<b.name
        return -1
      if a.name==b.name
        return 0
      return 1
    res.render 'index',
      title: "Browse - #{res.locals.path}"
      files:files

  

  app.get '/browse_README',(req,res,next)->
    res.locals.title="README"
    res.render 'markdown',
      markdown: converter.makeHtml fs.readFileSync __dirname+'/README','utf8'
      basename: 'README'


  app.post '*/browse_upload',(req,res,next)->
    if !res.locals.isEditor
      res.statusCode=403
      res.write "Permission denied."
      return res.end()
    if req.files.file.name.length
      fs.createReadStream(req.files.file.path).pipe(fs.createWriteStream(res.locals.resolved+'/'+ req.files.file.name))
    res.write "<script>location.href='#{req.params[0]||'/'}';</script>"
    res.end()


  app.all '*/browse_login',(req,res,next)->
    if res.locals.user?
      res.statusCode=302
      res.setHeader 'Location',req.params[0]||'/'
    else
      res.statusCode=401
      res.setHeader 'WWW-Authenticate','Basic realm="Browse"'
      res.write "<script>location.href='#{req.params[0]||'/'}';</script>"
    res.end()

  app.all '*/browse_logout',(req,res,next)->
    res.statusCode=401
    res.write "<script>location.href='#{req.params[0]||'/'}';</script>"
    res.end()

  app.get '*.markdown',(req,res,next)->
    res.locals.basename=path.basename req.params[0]
    res.locals.title="Markdown - #{res.locals.path}"
    if !fs.existsSync(res.locals.resolved+'/'+res.locals.basename)||fs.statSync(res.locals.resolved+'/'+res.locals.basename).isFile()
      res.render 'markdown',
        markdown: converter.makeHtml fs.readFileSync res.locals.resolved+'/'+res.locals.basename,'utf8'
    else
      next()
  app.get '*.view',(req,res)->
    res.locals.basename=path.basename req.params[0]
    res.render 'view',
      title: "View - #{res.locals.path}"
  app.all "*.edit", (req,res)->
    if !res.locals.isEditor
      res.statusCode=403
      res.write "Permission denied."
      return res.end()
    p=app.cfg.root+'/'+req.params[0]
    res.setHeader 'Content-Type','text/plain; charset=utf-8'
    try
      if req.body&&req.body.content
        fs.writeFileSync p,req.body.content,'utf8'
        if err
          throw err
    catch e
      res.statusCode=500
      res.write String e
      res.end()
    res.end()
