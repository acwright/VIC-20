TARGET = helloprg

.PHONY: all clean

all: build

build: $(TARGET).asm
	cl65 -t vic20 -l $(TARGET).lst -o $(TARGET).prg $(TARGET).asm
	
view:
	hexdump -C $(TARGET).prg

run:
	xvic $(TARGET).prg &> /dev/null

clean:
	rm $(TARGET).prg
	rm $(TARGET).lst