# FPGA Robot Arm

Potentiometer-controlled robot arm on a Basys 3 FPGA. Reads 5 pots through an MCP3008 ADC over SPI, maps each 10-bit value to a servo PWM signal. Round-robin channel cycling reads all 5 pots continuously.

## Hardware

- Basys 3 (Artix-7 XC7A35T)
- MCP3008 10-bit ADC
- 5x hobby servos
- 5x 10k ohm potentiometers
- 5V bench supply on J6 EXT + USB for programming

## Modules

- `pwm.v` - 50Hz PWM generator. 8-bit position input maps to 1ms-2ms pulse width.
- `clk_div.v` - Divides 100MHz board clock to 10kHz for SPI.
- `spi.v` - SPI controller for MCP3008. 24-clock conversation to read one channel.
- `top.v` - Wires everything together. Cycles through 5 MCP3008 channels, stores each result, drives 5 independent PWM outputs.

## Pin Mapping

- Pmod JC: servo 1 (K17), CS (M18), MOSI (N17), MISO (P18), SCLK (L17)
- Pmod JB: servo 2 (A14), servo 3 (A16), servo 4 (B15), servo 5 (B16)
- Center button (U18): reset

## Toolchain

Open-source: yosys, nextpnr-xilinx, prjxray, openFPGALoader.
