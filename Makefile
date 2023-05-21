hello_world: .hello_world.o
	gcc .hello_world.o -o hello_world

.hello_world.o: ./hello_world.c
	gcc -c ./hello_world.c -o .hello_world.o

install:
	install "./amboso" /usr/local/bin/anvil
	install "./amboso_fn.sh" /usr/local/bin/

uninstall:
	rm /usr/local/bin/anvil
	rm /usr/local/bin/amboso_fn.sh

clean:
	rm \.*.o hello_world

cleanob:
	rm \.*.o
