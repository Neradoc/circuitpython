// This file is part of the CircuitPython project: https://circuitpython.org
//
// SPDX-FileCopyrightText: Copyright (c) 2024 Scott Shawcroft for Adafruit Industries
//
// SPDX-License-Identifier: MIT

#define MICROPY_HW_BOARD_NAME "Adafruit Metro RP2350"
#define MICROPY_HW_MCU_NAME "rp2350b"

#define MICROPY_HW_NEOPIXEL (&pin_GPIO25)

#define DEFAULT_I2C_BUS_SCL (&pin_GPIO21)
#define DEFAULT_I2C_BUS_SDA (&pin_GPIO20)

#define DEFAULT_SPI_BUS_SCK (&pin_GPIO30)
#define DEFAULT_SPI_BUS_MOSI (&pin_GPIO31)
#define DEFAULT_SPI_BUS_MISO (&pin_GPIO28)

#define DEFAULT_UART_BUS_RX (&pin_GPIO1)
#define DEFAULT_UART_BUS_TX (&pin_GPIO0)

// #define CIRCUITPY_CONSOLE_UART_RX DEFAULT_UART_BUS_RX
// #define CIRCUITPY_CONSOLE_UART_TX DEFAULT_UART_BUS_TX

#define DEFAULT_USB_HOST_DATA_PLUS (&pin_GPIO32)
#define DEFAULT_USB_HOST_DATA_MINUS (&pin_GPIO33)
#define DEFAULT_USB_HOST_5V_POWER (&pin_GPIO29)
#define CIRCUITPY_PSRAM_CHIP_SELECT (&pin_GPIO47)
