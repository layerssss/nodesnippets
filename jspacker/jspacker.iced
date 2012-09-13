yaml=require 'js-yaml'
fs=require 'fs'
path=require 'path'

buf=[]
#buf.push '(function(){'
objects={}
for file in process.argv.slice 3
	dir=''
	ext=path.extname file
	file=file.split '/'
	if file.length>1
		for i in [1..file.length-1]
			dir=file.slice(0,i).join('.');
			if dir=='.'||dir==''
				dir=''
			else
				if !objects[dir]?
					objects[dir]=true
					buf.push "this.#{dir}={};"
	file=file.join '/'
	await fs.readFile file,'utf8',defer err,content
	if dir!=''
		dir='.'+dir

	if ext=='.js'
		content=content.replace(/^\/\/.*\n\r?/,'').replace(/.call\(this\);\r?\n?$/,'')
		buf.push "this#{dir}.#{path.basename file,ext}=#{content};"
	else if ext=='.json'
		buf.push "this#{dir}.#{path.basename file,ext}=#{content};"
	else
		buf.push "this#{dir}.#{path.basename file,ext}=#{JSON.stringify(content)};"
#buf.push '}).call(this);'
await fs.writeFile process.argv[2],buf.join(''),'utf8',defer err
setTimeout (->),300
