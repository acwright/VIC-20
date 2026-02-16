.PHONY: all clean

all: build/hello

build:
	mkdir -p build

build/hello: src/hello.asm build
	ca65 -v -t vic20 -l ./build/hello.list -o ./build/hello.o ./src/hello.asm
	cl65 -v -t vic20 -o ./build/hello.prg ./build/hello.o
	
view:
	hexdump -C ./build/hello.prg

run:
	xvic -silent ./build/hello.prg

clean:
	rm -rf build/