// https://wiki.osdev.org/Calling_Global_Constructors#x86_.2832-bit.29
.section .init
.global _init
.type _init, @function
_init:
    push %ebp
    movl %esp, %ebp
    /* gcc will nicely put the contents of crtbegin.o's .init section here. */

.section .fini
.global _fini
.type _fini, @function
_fini:
    push %ebp
    movl %esp, %ebp
    /* gcc will nicely put the contents of crtbegin.o's .fini section here. */
