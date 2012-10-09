test:
	@set -e
	@./node_modules/.bin/mocha \
	--reporter spec \
	-b \
	-t 10000 \
	-r coffee-script \
	--compilers coffee:coffee-script
		
.PHONY: test
