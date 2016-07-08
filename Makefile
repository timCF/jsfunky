REPORTER = spec
COMPILER = iced:iced-coffee-script/register

all:
	iced -c ./jsfunky.iced

test: all
	mocha --reporter $(REPORTER) --compilers $(COMPILER)

.PHONY: all test
