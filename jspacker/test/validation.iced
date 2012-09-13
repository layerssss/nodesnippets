assert = require 'assert'
fs=require 'fs'
cp=require 'child_process'
data={}
describe 'result.js', ->
	it 'should be a good JS',()->
		(new Function(fs.readFileSync('result.js','utf8'))).call(data)
describe 'result.js', ->
	describe 'jsfunction()',->
		it 'should contains good info',()->
			assert.equal data.test.files.jsfunction(),'passed'
describe 'result.js', ->
	describe 'icedfunction()',->
		it 'should contains good info',()->
			assert.equal data.test.files.icedfunction.func(),'passed'
describe 'result.js', ->
	describe 'folder.text',->
		it 'should contains good info',()->
			assert.equal data.test.files.folder.text,'passed'
describe 'result.js', ->
	describe 'jadetemplate.jade',->
		it 'should contains good info',()->
			assert.equal data.test.files.jadetemplate(),'<p>hello!</p>'
describe 'result.js', ->
	describe 'data.json',->
		it 'should contains good info',()->
			assert.equal data.test.files.data.user.name,'foo'