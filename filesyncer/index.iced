yaml=require 'js-yaml'
fs=require 'fs'
cfg=undefined
await fs.readFile "#{__dirname}/config.yaml",'utf8',defer err,file
if file?
	cfg=yaml.load file
await fs.readFile 'filesyncer.config.yaml','utf8',defer err,file
if file?
	cfg=yaml.load file
if process.argv.length>2
	await fs.readFile process.argv[2],'utf8',defer err,file
	if file?
		cfg=yaml.load file


for watching in cfg.watchings
	for file in watching
		fs.watchFile(file,{persistent:true,interval:800},()->
			files=this.watching
			files=files.map (f)->
					filename:f
					mtime:if fs.existsSync f then fs.statSync(f).mtime else null
			files=files.sort (f1,f2)->
				!f1.mtime or f1.mtime<f2.mtime
			try
				content=fs.readFileSync files[0].filename
				for f in files
					fs.writeFileSync f.filename,content
			catch e
		).watching=watching