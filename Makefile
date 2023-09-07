export SHELL=/bin/bash
VERSION="1.6.5"
ANVIL_C_HEADER_VERSION="1.6.5"
ECHO_VERSION="./amboso"
RUN_VERSION := $(shell $(ECHO_VERSION) -v)

all: hello_world
	@echo -e "\033[1;32mEnd of build.\e[0m\n"
.PHONY: all

hello_world: .hello_world.o .anvil__hello_world.o
	@echo -en "Building hello_world for amboso $(VERSION):    "
	gcc .hello_world.o .anvil__hello_world.o -o hello_world
	@echo -e "\033[1;33mDone.\e[0m"

.hello_world.o: ./example-src/hello_world.c ./example-src/anvil__hello_world.h ./example-src/anvil__hello_world.c
	@echo -en "Building .hello_world.o for amboso $(VERSION):    "
	gcc -c ./example-src/hello_world.c -o .hello_world.o
	@echo -e "\033[1;33mDone.\e[0m"

.anvil__hello_world.o: ./amboso ./amboso_fn.sh ./example-src/anvil__hello_world.c ./example-src/anvil__hello_world.h
	@echo -en "Building .anvil__hello_world.o:    "
	gcc -c ./example-src/anvil__hello_world.c -o .anvil__hello_world.o
	@echo -e "\033[1;33mDone.\e[0m"

./example-src/anvil__hello_world.c: ./amboso_fn.sh ./amboso
	@echo -en "Generating C anvil__hello_world for $(VERSION):    "
	-./amboso -G ./example-src $(ANVIL_C_HEADER_VERSION)
	@echo -e "\033[1;33mDone.\e[0m"

./example-src/anvil__hello_world.h: ./amboso_fn.sh ./amboso
	@echo -en "Generating C anvil__hello_world for $(VERSION):    "
	-./amboso -qG ./example-src $(ANVIL_C_HEADER_VERSION)
	@echo -e "\033[1;33mDone.\e[0m"

check: hello_world
	@echo -en "Checking amboso local version, expected ($(VERSION)):  got ($(RUN_VERSION))."
	test $(RUN_VERSION) = $(VERSION) || echo -en '\n    \033[1;31mFailed check for expected local version.\e[0m\n'
	@echo -e "\n\033[1;32mDone.\e[0m"

distcheck: hello_world
	@echo -en "Distchecking amboso $(VERSION):    "
	echo -e "Feeling good.\n"
	@echo -e "\033[1;32mSuccess.\e[0m"

pack: hello_world
	@echo -en "Packing amboso $(VERSION):    "
	echo -e "Feeling good.\n"
	@echo -e "\033[1;32mSuccess.\e[0m"

install:
	@echo -en "Installing amboso $(VERSION) globally as 'anvil':    "
	install "./amboso" /usr/local/bin/anvil
	@echo -en "Installing amboso_fn.sh $(VERSION) globally as inside '/usr/local/bin':"
	install "./amboso_fn.sh" /usr/local/bin/
	@echo -e "\033[1;33mDone.\e[0m"

uninstall:
	@echo -en "Uninstalling amboso $(VERSION) globally as 'anvil':    "
	rm /usr/local/bin/anvil
	rm /usr/local/bin/amboso_fn.sh
	@echo -e "\033[1;33mDone.\e[0m"

clean:
	@echo -en "Cleaning build artifacts:    "
	-rm \.*.o hello_world
	-rm ./example-src/*.o
	-rm ./example-src/anvil__hello_world.*
	@echo -e "\033[1;33mDone.\e[0m"

cleanob:
	@echo -en "Cleaning object build artifacts:    "
	-rm \.*.o
	-rm ./example-src/*.o
	@echo -e "\033[1;33mDone.\e[0m"

rebuild: clean all

$(V).SILENT:
