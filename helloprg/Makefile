TARGET = helloprg
CONFIG = vic20

.PHONY: all clean

all: build

build: $(TARGET).asm
	cl65 -C ../$(CONFIG).cfg -l $(TARGET).lst -o $(TARGET).prg $(TARGET).asm 
	
view:
	hexdump -C $(TARGET).prg

run:
	xvic $(TARGET).prg &> /dev/null

clean:
	rm $(TARGET).prg
	rm $(TARGET).lst