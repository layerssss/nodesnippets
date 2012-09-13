ICED = $(shell find . -name '*.iced')
JS = $(ICED:.iced=.js)



all:$(JS)
%.js: %.iced
	iced -c $<