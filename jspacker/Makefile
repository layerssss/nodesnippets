TESTICED = $(shell find test -name '*.iced')

TESTJADE = $(shell find test -name '*.jade')
TESTJS = $(TESTICED:.iced=.js)

TESTFILES = $(shell find test/files|grep '[^\/]\.[^i]')


all: jspacker.js
%.js: %.iced
	iced -c $<
test/files/jadetemplate.js: test/jadetemplate.jade
	jade -c $<
	mv test/jadetemplate.js test/files/jadetemplate.js

		
test: $(TESTJS) test/files/jadetemplate.js test/validation.js
	rm -f result.js
	node ./jspacker result.js $(TESTFILES)
	mocha


.PHONY: test