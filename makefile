test:
	@set -e
	@./node_modules/.bin/mocha \
	--reporter spec \
	-t 10000 \
	-r coffee-script \
	--compilers coffee:coffee-script \
	--bail $(ARGS)
	

compile:
	rm -rf ./dist
	mkdir -p ./dist
	coffee --output ./dist/ --compile ./lib/

lint:
	@./node_modules/.bin/coffeelint -f .coffeelint.json -r ./lib 
		
build: lint test compile
		
.PHONY: test compile build lint
