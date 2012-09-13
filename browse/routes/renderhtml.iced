exports.renderhtml=(req,res)->
	nurl=require 'url'
	res.write decodeURIComponent(nurl.parse(req.url).query)
	res.end()