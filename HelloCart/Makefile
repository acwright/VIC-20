TARGET = HelloCart
CONFIG = VIC20-8K

.PHONY: all clean

all: build

build: $(TARGET).asm
	cl65 -C ../$(CONFIG).cfg -l $(TARGET).lst -o $(TARGET).crt $(TARGET).asm
	
view:
	hexdump -C $(TARGET).crt

run:
	xvic -cartA $(TARGET).crt &> /dev/null

clean:
	rm -f $(TARGET).crt $(TARGET).lst
