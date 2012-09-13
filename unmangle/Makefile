
ICED = $(shell find . -name '*.iced')
JS = $(ICED:.iced=.js)

%.js:%.iced
	iced -c $<

all:$(JS)

test:all test/tests.js
	mocha
	
.PHONY:test