this.test={};this.test.files={};this.test.files.folder={};this.test.files.folder.text="passed";this.test.files.jsfunction=function func(){
	return 'passed'
};this.test.files.data={"user":{"name":"foo"}};this.test.files.jadetemplate=function anonymous(locals, attrs, escape, rethrow, merge) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow, merge = jade.merge;
var __jade = [{ lineno: 1, filename: "test/jadetemplate.jade" }];
try {
var buf = [];
with (locals || {}) {
var interp;
__jade.unshift({ lineno: 1, filename: __jade[0].filename });
__jade.unshift({ lineno: 1, filename: __jade[0].filename });
buf.push('<p>');
__jade.unshift({ lineno: undefined, filename: __jade[0].filename });
__jade.unshift({ lineno: 1, filename: __jade[0].filename });
buf.push('hello!');
__jade.shift();
__jade.shift();
buf.push('</p>');
__jade.shift();
__jade.shift();
}
return buf.join("");
} catch (err) {
  rethrow(err, __jade[0].filename, __jade[0].lineno);
}
};this.test.files.icedfunction=(function() {

  this.func = function() {
    return 'passed';
  };

  return this;

});