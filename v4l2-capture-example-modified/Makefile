CFLAGS = `pkg-config --cflags opencv`
LIBS = `pkg-config --libs opencv`

default: capture-example

rt_timer.o: src/rt_timer.c src/rt_timer.h
	g++ -std=c++11 -c src/rt_timer.c

capture-example.o: src/capture-example.cpp
	g++ -std=c++11 -c src/capture-example.cpp -o capture-example.o

capture-example: rt_timer.o capture-example.o 
	g++ -std=c++11 -o capture-example rt_timer.o capture-example.o $(CFLAGS) $(LIBS)

