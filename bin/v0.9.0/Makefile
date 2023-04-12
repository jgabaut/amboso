hello_world: .hello_world.o
	gcc .hello_world.o -o hello_world

.hello_world.o: ./hello_world.c
	gcc -c ./hello_world.c -o .hello_world.o

clean:
	rm \.*.o hello_world

cleanob:
	rm \.*.o
