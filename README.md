VIC-20
======

This is a collection of my VIC-20 assembly language programs.

## Building Everything

The root Makefile builds every subproject in one shot. It walks the top-level
directories and recurses into any that has its own Makefile, so adding a new
program is just a matter of dropping in a directory — no edits to the root
Makefile required.

```bash
make        # Build every program
make clean  # Remove every program's build artifacts
```

## Building Programs

Each program directory contains its own Makefile. To build a single program,
navigate to its directory and use `make`.

### Available Targets

- `make` or `make all` - Build the program
- `make view` - Display hexdump of the built program
- `make run` - Run the program in the xvic emulator
- `make clean` - Remove build artifacts

### Example

```bash
cd <directory-name>
make        # Build the program
make view   # View the hexdump
make run    # Run in emulator
```
