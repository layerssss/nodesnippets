fs=require 'fs'
yaml=require 'js-yaml'
unmangle=require './unmangle'
http=require 'http'
nurl=require 'url'
__cookie=''
__request=(url,cb)->
	d=''
	url=nurl.parse url
	url.headers=
		'Cookie':__cookie
	req=http.request url,(res)->
		if res.statusCode!=200
			cb res.statusCode
			return
		if res.headers['set-cookie']?
			__cookie=res.headers['set-cookie']
		res.setEncoding 'utf8'
		res.on 'data',(chunk)->
			d+=chunk
		res.on 'end',()->
			cb null,d
	req.end()

exec=require('child_process').exec
cfg=yaml.load fs.readFileSync process.argv[2],'utf8'
datafiles=fs.readdirSync(process.argv[3]).map (tf)->
	if !tf.match /\.yaml$/
		return
	return tf
data={}
for datafile in datafiles
	data[datafile]=fs.readFileSync process.argv[3]+'/'+datafile,'utf8'

buf=[]
buf.push 'assert=require "assert"\n'
buf.push 'dSet=(jsonp)->if jsonp.statusCode==200 then jsonp.data else jsonp.message\n'
buf.push 'type=(obj)->if !obj? then "undefined" else if obj.constructor==Array then "array" else if obj.constructor==Date then "string" else typeof obj\n'
type=(obj)->if !obj? then "undefined" else if obj.constructor==Array then "array" else if obj.constructor==Date then "string" else typeof obj
jsonp=''
for init in cfg.init
	console.log "fetching #{init.url}..."
	if !init.url.match /\?/
		init.url+='?'
	await __request "#{cfg.baseurl}#{init.url}&callback=dSet&dataType=jsonp",defer err,jsonp
	if err?
		throw Error(jsonp)

traverse=(obj,indent,path='')->
	t=type(obj)
	buf.push indent+"it 'should be a \"#{t}\"',->\n"
	buf.push indent+"\tdata=#{jsonp.trim()}\n"
	buf.push indent+"\tassert.equal type(data#{path}),'#{t}'\n"
	if t=='array'
		buf.push indent+"it 'should has at least one element',->\n"
		buf.push indent+"\tdata=#{jsonp.trim()}\n"
		buf.push indent+"\tassert.equal data#{path}.length>0,true\n"
		buf.push indent+"describe '[0]',->\n"
		traverse obj[0],indent+'\t',path+'[0]'
	if t=='object'
		for k,v of obj
			buf.push indent+"describe '.#{k}',->\n"
			traverse v,indent+'\t',path+'.'+k
testname=null
try
	testname=process.argv[5].trim()
catch e
	console.log e
for test,i in cfg.tests
	if !testname? || testname==test.name
		console.log "fetching #{test.url}..."
		if !test.url.match /\?/
			test.url+='?'
		[url,query]=test.url.match(/^([^\?]+)(\??.*)/).slice 1
		await __request "#{cfg.baseurl}#{test.url}&callback=dSet&dataType=jsonp",defer err,jsonp
		if err?
			throw Error(jsonp)
		obj=yaml.load unmangle.unmangle(data[url+'.yaml'],query)
		buf.push "describe '#{url}#{query}',->\n"
		traverse obj,'\t'


fs.writeFileSync process.argv[4],buf.join(''),'utf8'