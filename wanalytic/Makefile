ICEDBIN = node_modules/.bin/iced
BOWERBIN = node_modules/.bin/bower
all: components node_modules

components: node_modules bower.json 
	$(BOWERBIN) install
	find . -type f -name *.css -exec perl -e "s/\@import\surl\(.*//g;" -pi.save {} \;
	touch $@
node_modules: package.json
	npm install
	npm install bower
	touch $@


.PHONY:

clean:
	rm -Rf `cat .gitignore`

