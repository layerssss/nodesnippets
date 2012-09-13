// Generated by IcedCoffeeScript 1.3.3d
(function() {
  var buf, cfg, data, datafile, datafiles, err, exec, fs, http, i, iced, init, jsonp, nurl, obj, query, test, testname, traverse, type, unmangle, url, yaml, __cookie, __iced_deferrals, __iced_k, __iced_k_noop, __request, _i, _len,
    _this = this;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  fs = require('fs');

  yaml = require('js-yaml');

  unmangle = require('./unmangle');

  http = require('http');

  nurl = require('url');

  __cookie = '';

  __request = function(url, cb) {
    var d, req;
    d = '';
    url = nurl.parse(url);
    url.headers = {
      'Cookie': __cookie
    };
    req = http.request(url, function(res) {
      if (res.statusCode !== 200) {
        cb(res.statusCode);
        return;
      }
      if (res.headers['set-cookie'] != null) __cookie = res.headers['set-cookie'];
      res.setEncoding('utf8');
      res.on('data', function(chunk) {
        return d += chunk;
      });
      return res.on('end', function() {
        return cb(null, d);
      });
    });
    return req.end();
  };

  exec = require('child_process').exec;

  cfg = yaml.load(fs.readFileSync(process.argv[2], 'utf8'));

  datafiles = fs.readdirSync(process.argv[3]).map(function(tf) {
    if (!tf.match(/\.yaml$/)) return;
    return tf;
  });

  data = {};

  for (_i = 0, _len = datafiles.length; _i < _len; _i++) {
    datafile = datafiles[_i];
    data[datafile] = fs.readFileSync(process.argv[3] + '/' + datafile, 'utf8');
  }

  buf = [];

  buf.push('assert=require "assert"\n');

  buf.push('dSet=(jsonp)->if jsonp.statusCode==200 then jsonp.data else jsonp.message\n');

  buf.push('type=(obj)->if !obj? then "undefined" else if obj.constructor==Array then "array" else if obj.constructor==Date then "string" else typeof obj\n');

  type = function(obj) {
    if (!(obj != null)) {
      return "undefined";
    } else if (obj.constructor === Array) {
      return "array";
    } else if (obj.constructor === Date) {
      return "string";
    } else {
      return typeof obj;
    }
  };

  jsonp = '';

  (function(__iced_k) {
    var _j, _len1, _ref, _results, _while;
    _ref = cfg.init;
    _len1 = _ref.length;
    _j = 0;
    _results = [];
    _while = function(__iced_k) {
      var _break, _continue, _next;
      _break = function() {
        return __iced_k(_results);
      };
      _continue = function() {
        ++_j;
        return _while(__iced_k);
      };
      _next = function(__iced_next_arg) {
        _results.push(__iced_next_arg);
        return _continue();
      };
      if (!(_j < _len1)) {
        return _break();
      } else {
        init = _ref[_j];
        console.log("fetching " + init.url + "...");
        if (!init.url.match(/\?/)) init.url += '?';
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            filename: "datatestgen.iced"
          });
          __request("" + cfg.baseurl + init.url + "&callback=dSet&dataType=jsonp", __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return jsonp = arguments[1];
              };
            })(),
            lineno: 45
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (err != null) throw Error(jsonp);
          return _next();
        });
      }
    };
    _while(__iced_k);
  })(function() {
    traverse = function(obj, indent, path) {
      var k, t, v, _results;
      if (path == null) path = '';
      t = type(obj);
      buf.push(indent + ("it 'should be a \"" + t + "\"',->\n"));
      buf.push(indent + ("\tdata=" + (jsonp.trim()) + "\n"));
      buf.push(indent + ("\tassert.equal type(data" + path + "),'" + t + "'\n"));
      if (t === 'array') {
        buf.push(indent + "it 'should has at least one element',->\n");
        buf.push(indent + ("\tdata=" + (jsonp.trim()) + "\n"));
        buf.push(indent + ("\tassert.equal data" + path + ".length>0,true\n"));
        buf.push(indent + "describe '[0]',->\n");
        traverse(obj[0], indent + '\t', path + '[0]');
      }
      if (t === 'object') {
        _results = [];
        for (k in obj) {
          v = obj[k];
          buf.push(indent + ("describe '." + k + "',->\n"));
          _results.push(traverse(v, indent + '\t', path + '.' + k));
        }
        return _results;
      }
    };
    testname = null;
    try {
      testname = process.argv[5].trim();
    } catch (e) {
      console.log(e);
    }
    (function(__iced_k) {
      var _j, _len1, _ref, _results, _while;
      _ref = cfg.tests;
      _len1 = _ref.length;
      i = 0;
      _results = [];
      _while = function(__iced_k) {
        var _break, _continue, _next;
        _break = function() {
          return __iced_k(_results);
        };
        _continue = function() {
          ++i;
          return _while(__iced_k);
        };
        _next = function(__iced_next_arg) {
          _results.push(__iced_next_arg);
          return _continue();
        };
        if (!(i < _len1)) {
          return _break();
        } else {
          test = _ref[i];
          (function(__iced_k) {
            var _ref1;
            if (!(testname != null) || testname === test.name) {
              console.log("fetching " + test.url + "...");
              if (!test.url.match(/\?/)) test.url += '?';
              _ref1 = test.url.match(/^([^\?]+)(\??.*)/).slice(1), url = _ref1[0], query = _ref1[1];
              (function(__iced_k) {
                __iced_deferrals = new iced.Deferrals(__iced_k, {
                  filename: "datatestgen.iced"
                });
                __request("" + cfg.baseurl + test.url + "&callback=dSet&dataType=jsonp", __iced_deferrals.defer({
                  assign_fn: (function() {
                    return function() {
                      err = arguments[0];
                      return jsonp = arguments[1];
                    };
                  })(),
                  lineno: 75
                }));
                __iced_deferrals._fulfill();
              })(function() {
                if (typeof err !== "undefined" && err !== null) throw Error(jsonp);
                obj = yaml.load(unmangle.unmangle(data[url + '.yaml'], query));
                buf.push("describe '" + url + query + "',->\n");
                return __iced_k(traverse(obj, '\t'));
              });
            } else {
              return __iced_k();
            }
          })(_next);
        }
      };
      _while(__iced_k);
    })(function() {
      return fs.writeFileSync(process.argv[4], buf.join(''), 'utf8');
    });
  });

}).call(this);
