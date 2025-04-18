/* Based on GCC ARM embedded samples.
   Defines the following symbols for use by code:
    __exidx_start
    __exidx_end
    __etext
    __data_start__
    __preinit_array_start
    __preinit_array_end
    __init_array_start
    __init_array_end
    __fini_array_start
    __fini_array_end
    __data_end__
    __bss_start__
    __bss_end__
    __end__
    end
    __HeapLimit
    __StackLimit
    __StackTop
    __stack (== StackTop)
*/

firmware_size = DEFINED(firmware_size) ? firmware_size : 1020K ;

MEMORY
{
    FLASH_FIRMWARE (rx) : ORIGIN = 0x10000000, LENGTH = firmware_size
    /* Followed by: 4kB of NVRAM and at least 1024kB of CIRCUITPY */
    RAM (rwx) : ORIGIN =  0x20000000, LENGTH = 512k
    SCRATCH_Y (rwx) : ORIGIN = 0x20080000, LENGTH = 4k
    /* X is used by core 1 so we put it last. */
    SCRATCH_X (rwx) : ORIGIN = 0x20081000, LENGTH = 4k
}

ENTRY(_entry_point)

SECTIONS
{
    /* Second stage bootloader is prepended to the image. It must be 256 bytes big
       and checksummed. It is usually built by the boot_stage2 target
       in the Pico SDK
    */

    .flash_begin : {
        __flash_binary_start = .;
    } > FLASH_FIRMWARE

    .text : {
        __logical_binary_start = .;
        KEEP (*(.vectors))
        KEEP (*(.binary_info_header))
        __binary_info_header_end = .;
        KEEP (*(.embedded_block))
        __embedded_block_end = .;
        KEEP (*(.reset))
        *(.init)

        __property_getter_start = .;
        *(.property_getter)
        __property_getter_end = .;
        __property_getset_start = .;
        *(.property_getset)
        __property_getset_end = .;

        *(EXCLUDE_FILE(*libgcc.a: *libc.a:*lib_a-mem*.o *libm.a: *interp.o *divider.o *tusb_fifo.o *mem_ops_aeabi.o *usbh.o *string0.o) .text*)
        /* Allow everything in usbh.o except tuh_task_event_ready because we read it from core 1. */
        *usbh.o (.text.[_uphc]* .text.tuh_[cmved]* .text.tuh_task_ext*)
        *(.fini)
        /* Pull all c'tors into .text */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)
        /* Followed by destructors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)

        *(.eh_frame*)
        . = ALIGN(4);
    } > FLASH_FIRMWARE

    .rodata : {
        *(EXCLUDE_FILE(*libgcc.a: *libc.a:*lib_a-mem*.o *libm.a:) .rodata*)
        . = ALIGN(4);
        *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.flashdata*)))
        . = ALIGN(4);
    } > FLASH_FIRMWARE

    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > FLASH_FIRMWARE

    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > FLASH_FIRMWARE
    __exidx_end = .;

    /* Machine inspectable binary information */
    . = ALIGN(4);
    __binary_info_start = .;
    .binary_info :
    {
        KEEP(*(.binary_info.keep.*))
        *(.binary_info.*)
    } > FLASH_FIRMWARE
    __binary_info_end = .;
    . = ALIGN(4);

    /* End of .text-like segments */
    __etext = .;

   .ram_vector_table (NOLOAD): {
        *(.ram_vector_table)
    } > RAM

    .data : {
        __data_start__ = .;
        *(vtable)

        *(EXCLUDE_FILE(*tmds_encode.o) .time_critical*)

        /* remaining .text and .rodata; i.e. stuff we exclude above because we want it in RAM */
        *(.text*)
        . = ALIGN(4);
        *(.rodata*)
        . = ALIGN(4);

        *(.data*)

        . = ALIGN(4);
        *(.after_data.*)
        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__mutex_array_start = .);
        KEEP(*(SORT(.mutex_array.*)))
        KEEP(*(.mutex_array))
        PROVIDE_HIDDEN (__mutex_array_end = .);

        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(SORT(.preinit_array.*)))
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);

        . = ALIGN(4);
        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);

        . = ALIGN(4);
        /* finit data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        *(SORT(.fini_array.*))
        *(.fini_array)
        PROVIDE_HIDDEN (__fini_array_end = .);

        *(.jcr)
        . = ALIGN(4);
        /* All data end */
        __data_end__ = .;
    } > RAM AT> FLASH_FIRMWARE

    .itcm :
    {
        . = ALIGN(4);
        *(.itcm.*)

        . = ALIGN(4);
    } > RAM AT> FLASH_FIRMWARE
    _ld_itcm_destination = ADDR(.itcm);
    _ld_itcm_flash_copy = LOADADDR(.itcm);
    _ld_itcm_size = SIZEOF(.itcm);

    .dtcm_data :
    {
        . = ALIGN(4);

        *(.dtcm_data.*)

        . = ALIGN(4);
    } > RAM AT> FLASH_FIRMWARE
    _ld_dtcm_data_destination = ADDR(.dtcm_data);
    _ld_dtcm_data_flash_copy = LOADADDR(.dtcm_data);
    _ld_dtcm_data_size = SIZEOF(.dtcm_data);

    .dtcm_bss (NOLOAD) :
    {
        . = ALIGN(4);

        *(.dtcm_bss.*)

        . = ALIGN(4);
    } > RAM AT> RAM
    _ld_dtcm_bss_start = ADDR(.dtcm_bss);
    _ld_dtcm_bss_size = SIZEOF(.dtcm_bss);

    .uninitialized_data (COPY): {
        . = ALIGN(4);
        *(.uninitialized_data*)
    } > RAM

    .bss  : {
        . = ALIGN(4);
        __bss_start__ = .;
        *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.bss*)))
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    .heap (COPY):
    {
        __end__ = .;
        end = __end__;
        _ld_cp_dynamic_mem_start = .;
        *(.heap*)
        __HeapLimit = .;
    } > RAM

    /* Start and end symbols must be word-aligned */
    .scratch_x : {
        __scratch_x_start__ = .;
        *(.scratch_x.*)
        *tmds_encode.o (.time_critical*)
        *timer.o (.text.hardware_alarm_irq_handler)
        . = ALIGN(4);
        __scratch_x_end__ = .;
    } > SCRATCH_X AT > FLASH_FIRMWARE
    __scratch_x_source__ = LOADADDR(.scratch_x);

    .scratch_y : {
        __scratch_y_start__ = .;
        /* Don't put anything into scratch y because CircuitPython manages it and uses it for core 0 stack.
        /* *(.scratch_y.*) */
        . = ALIGN(4);
        __scratch_y_end__ = .;
    } > SCRATCH_Y AT > FLASH_FIRMWARE
    __scratch_y_source__ = LOADADDR(.scratch_y);

    /* .stack*_dummy section doesn't contains any symbols. It is only
     * used for linker to calculate size of stack sections, and assign
     * values to stack symbols later
     *
     * stack1 section may be empty/missing if platform_launch_core1 is not used */

    /* by default we put core 0 stack at the end of scratch Y, so that if core 1
     * stack is not used then all of SCRATCH_X is free.
     */
    .stack1_dummy (COPY):
    {
        *(.stack1*)
    } > SCRATCH_X

    .stack_dummy (COPY):
    {
        *(.stack*)
    } > SCRATCH_Y

    .flash_end : {
        __flash_binary_end = .;
    } > FLASH_FIRMWARE

    /* stack limit is poorly named, but historically is maximum heap ptr */
    __StackLimit = ORIGIN(RAM) + LENGTH(RAM);
    __StackOneTop = ORIGIN(SCRATCH_X) + LENGTH(SCRATCH_X);
    __StackTop = ORIGIN(SCRATCH_Y) + LENGTH(SCRATCH_Y);
    _ld_cp_dynamic_mem_end = __StackTop;
    __StackOneBottom = __StackOneTop - SIZEOF(.stack1_dummy);
    __StackBottom = __StackTop - SIZEOF(.stack_dummy);
    PROVIDE(__stack = __StackTop);

    /* Check if data + heap + stack exceeds RAM limit */
    ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed")

    ASSERT( __binary_info_header_end - __logical_binary_start <= 1024, "Binary info must be in first 1024 bytes of the binary")
    /* todo assert on extra code */
}
