CC=scarts_32-none-eabi-gcc
OBJCOPY=scarts_32-none-eabi-objcopy
OBJDUMP=scarts_32-none-eabi-objdump
CFLAGS=-c -Wall -O2
LDFLAGS=-Wl,--nmagic,--no-check-sections,--strip-all,-Tscarts_32-de2-115.ld
LIBS=-lscartsdrivers

SOURCES=src/main.c \
	src/but_sw_led.c \
	src/timer.c
	
OBJECTS=$(SOURCES:.c=.o)
PROGRAM=main
INCLUDE=-Iinclude

CFLAGS+=$(INCLUDE)

ifeq ($(DEBUG), 1)
  CFLAGS+=-g
endif

ifeq ($(TEST), 1)
  CFLAGS+=-DTEST
endif

all: tags $(SOURCES) $(PROGRAM)

tags: src/*.c include/*.h
	ctags src/*.c include/*.h

$(PROGRAM): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $@ 
	$(OBJCOPY) -O srec $(PROGRAM) $(PROGRAM).srec
	$(OBJDUMP) -DGlrswxz $(PROGRAM) > $(PROGRAM).txt

.c.o:
	$(CC) $(CFLAGS) $< -o $@

install:
	./serial_config.sh lab init
	./serial_config.sh lab write main.srec	

hinstall:
	./serial_config.sh home init
	./serial_config.sh home write main.srec	

clean:
	rm -rf $(OBJECTS) $(PROGRAM) $(PROGRAM).txt $(PROGRAM).srec
