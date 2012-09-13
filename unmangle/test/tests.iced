assert=require 'assert'
yaml=require 'js-yaml'
fs=require 'fs'
mangledyaml=require '../unmangle'
describe 'a.yaml',->
	it 'should pass',->
		result=mangledyaml.unmangle(fs.readFileSync('test/files/a.mangled.yaml','utf8'),'result=mail')
		assert.equal result.trim(),fs.readFileSync('test/files/a.unmangled.yaml','utf8').trim()
describe 'b.yaml',->
	it 'should pass',->
		result=mangledyaml.unmangle(fs.readFileSync('test/files/b.mangled.yaml','utf8'),'result=browser')
		assert.equal result.trim(),fs.readFileSync('test/files/b.unmangled.yaml','utf8').trim()