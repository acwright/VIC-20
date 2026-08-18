TARGET = smileyquest
CONFIG = vic20-8k
SOURCES = $(TARGET).asm defs.asm state.asm start.asm game.asm \
          gameover.asm input.asm screen.asm chars.asm

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
