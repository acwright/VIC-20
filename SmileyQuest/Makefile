TARGET = SmileyQuest
CONFIG = VIC20-8K
SOURCES = $(TARGET).asm Defs.asm State.asm Start.asm Game.asm \
          GameOver.asm Input.asm Screen.asm Chars.asm

.PHONY: all clean

all: build

build: $(SOURCES)
	cl65 -C ../$(CONFIG).cfg -l $(TARGET).lst -o $(TARGET).crt $(TARGET).asm

view:
	hexdump -C $(TARGET).crt

run:
	xvic -cartA $(TARGET).crt &> /dev/null

clean:
	rm -f $(TARGET).crt $(TARGET).lst
