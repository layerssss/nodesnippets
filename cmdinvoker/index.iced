http=require 'http'
fs=require 'fs'
cp=require 'child_process'
port=80
settings="#{__dirname}/settings.json"
if process.argv.length>2
	port=Number(process.argv[2])
if process.argv.length>3
	settings=process.argv[3]

exec=(cwd,cmd,cb)->
	msg=''
	output=''
	c=cp.exec cmd,{stdio: 'inherit',cwd:cwd}
	c.stdout.setEncoding 'utf8'
	c.stderr.setEncoding 'utf8'

	c.stdout.on 'data',(data)->
		if data? and data.trim().length
			if verbose?
				output+= data+'\r\n'
			else
				msg+=data
	c.stderr.on 'data',(data)->
		if data? and data.trim().length
			if verbose?
				output+= data+'\r\n'
			else
				msg+=data
	c.on 'exit',(code,sig)->
		if code!=0
			output+= "ERROR(exited with #{code})\r\n"
			output+= msg+'\r\n'
		cb(code!=0,msg)

await fs.readFile settings,'utf8',defer err,settings
settings=JSON.parse settings
server=http.createServer (req,res)->
	req=req.url.substring(1)
	res.setHeader 'Content-Type','text/plain'
	cmd=settings[req]
	if cmd?
		await exec cmd.cwd,cmd.cmd,defer err,msg
		res.write msg
		if err
			res.statusCode=500
	else
		res.statusCode=404
		res.write "#{req} not found...\r\n"
		res.write "Available commands:\r\n"
		for cmd of settings
			res.write "#{cmd};\r\n"
		res.write "visit /commandName to invoke...\r\n"

	res.end()
server.listen port
