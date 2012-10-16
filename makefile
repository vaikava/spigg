test:
	@set -e
	@./node_modules/.bin/mocha \
	--reporter spec \
	-t 10000 \
	-r coffee-script \
	--compilers coffee:coffee-script \
	--bail
		
.PHONY: test
