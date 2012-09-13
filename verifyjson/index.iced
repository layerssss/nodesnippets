fs=require 'fs'
http=require 'http'
yaml=require 'js-yaml'
fname=process.argv[2]
if !fname?
	console.log 'see my README'
	return
datatype='json'
if fname.match /jsonp/
	datatype='jsonp'
else if fname.match /json/
	datatype='json'
else if fname.match /yaml/
	datatype='yaml'

_jsonp=(jsonp)->
	try
		cb=jsonp.match(/([A-z\d_]+)\({/)[1]
	catch e
	 	throw new Error('format error!')
	if !cb?
		throw new Error('format error!')
	d={};
	this[cb]=(data)=>
		d=data
		d._jsonpSet=true
	try
		eval jsonp
	catch e
	 	throw new Error('format error!')
	if !d._jsonpSet
		throw new Error('format error!')
	delete d._jsonpSet
	return d

await fs.readFile fname,'utf8',defer err,file


try
	d={}
	if datatype=='jsonp'
		d=_jsonp file
	if datatype=='json'
		d=JSON.stringify file
	if datatype=='yaml'
		d=yaml.load file

	for k,v of d
		if v.constructor==Array
			if !v.length
				throw new Error("contains an empty Array!")
	process.exit 0
catch error
	  console.error error.message
	  process.exit 1
