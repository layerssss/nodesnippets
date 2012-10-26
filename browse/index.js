
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , path=require('path');
var app = module.exports = express.createServer();

// Configuration
var port=80
if(process.argv.length>2){
  port=Number(process.argv[2]);
}
app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.compress({
    filter:function(req,res){
      ctype=res.getHeader('Content-Type');
      return ctype!=null&&ctype.match(/json|text|javascript/)!=null;
    }
  }));
  app.use(express.static(path.dirname(path.dirname(__dirname))));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Routes
app.get('*/', routes.index);
app.get('*', routes.data);
app.get('*/make*.result.txt', routes.makeresult);
app.get('*/edit', routes.edit);
app.post('*/edit', routes.edit);
app.post('*/upload', routes.upload);
app.get('*/view', routes.view);
app.get('*/make*', routes.make);
app.get('*.jsonp/[^\.]+',function(req,res,next){
  res.setHeader('Content-Type','text/javascript; charset=utf8')
  next();
})
app.get('*.json/[^\.]+',function(req,res,next){
  res.setHeader('Content-Type','text/json; charset=utf8')
  next();
})

app.listen(port, function(){
  console.log("Express server listening");
});
