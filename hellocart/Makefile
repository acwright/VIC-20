TARGET = hellocart

.PHONY: all clean

all: build

build: $(TARGET).asm
	cl65 -C vic20-8k.cfg -t vic20 -l $(TARGET).lst -o $(TARGET).crt $(TARGET).asm
	
view:
	hexdump -C $(TARGET).crt

run:
	xvic -cartA $(TARGET).crt &> /dev/null

clean:
	rm $(TARGET).crt
	rm $(TARGET).lst