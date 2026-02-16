TARGET = hellocart
CONFIG = vic20-8k

.PHONY: all clean

all: build

build: $(TARGET).asm
	cl65 -C ../$(CONFIG).cfg -l $(TARGET).lst -o $(TARGET).crt $(TARGET).asm
	
view:
	hexdump -C $(TARGET).crt

run:
	xvic -cartA $(TARGET).crt &> /dev/null

clean:
	rm $(TARGET).crt
	rm $(TARGET).lst