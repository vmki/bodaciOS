arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso
linker_script := kernel/arch/$(arch)/linker.ld
grub_cfg := grub.cfg

asm_input_files := $(wildcard kernel/arch/$(arch)/*.S)
asm_output_files := $(patsubst kernel/arch/$(arch)/%.S, build/arch/$(arch)/%.o, $(asm_input_files))

c_input_files := $(wildcard kernel/core/*/*.c)
c_output_files := $(c_input_files:kernel/%.c=build/arch/$(arch)/%.o)

libc_input_files := $(wildcard libc/string/*.c)
libc_output_files := $(patsubst libc/string/%.c, build/arch/$(arch)/%.o, $(libc_input_files))

.PHONY: all clean run iso kernel

all: $(libc_output_files) $(c_output_files) kernel link

clean:
	@rm -r build

run: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

iso: $(iso)

prepare:
	@mkdir -p build/arch/$(arch)

$(iso): prepare all 
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	@rm -r build/isofiles

link: prepare $(asm_output_files) $(linker_script)
	@x86_64-elf-ld -n -o build/kernel-$(arch).bin -T $(linker_script) $(wildcard build/arch/$(arch)/*.o)

kernel:
	@x86_64-elf-gcc -std=gnu99 -ffreestanding -g -c kernel/kernel.c -o build/arch/$(arch)/kernel.o -I libc/include -I kernel/core/include

# assembly
build/arch/$(arch)/%.o: kernel/arch/$(arch)/%.S
	@mkdir -p $(shell dirname $@)
	@nasm -felf64 $< -o $@

# c kernel code
build/arch/$(arch)/%.o: $(c_input_files)
	@x86_64-elf-gcc -std=gnu99 -ffreestanding -g -c $< -o build/arch/$(arch)/$(notdir $@) -I libc/include -I kernel/core/include

# libc
$(libc_output_files): $(libc_input_files) prepare
	@mkdir -p $(shell dirname $@)
	@x86_64-elf-gcc -MD -c $< -o $@ -std=gnu11 -ffreestanding -Wall -Wextra -Iinclude
