# System Clock
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports clk_24mhz]

# PMOD J16 (Top Row) - I2C for GY-521
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 PULLUP true } [get_ports sda]
set_property -dict { PACKAGE_PIN R3 IOSTANDARD LVCMOS33 PULLUP true } [get_ports scl]

# 4x4 Keypad - Pin A13 (Manual Reset)
set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 PULLUP true } [get_ports key_0]

# User LEDs (Diagnostic Output for Gyro Spikes)
set_property -dict { PACKAGE_PIN D5 IOSTANDARD LVCMOS33 } [get_ports led1]
set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 } [get_ports led2]
set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 } [get_ports led3]
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports led4]

# MAX7219 7-Segment SPI Pins
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports seg_din]
set_property -dict { PACKAGE_PIN J16 IOSTANDARD LVCMOS33 } [get_ports seg_cs]
set_property -dict { PACKAGE_PIN H12 IOSTANDARD LVCMOS33 } [get_ports seg_clk]

# Active Piezo Buzzer
set_property -dict { PACKAGE_PIN K5 IOSTANDARD LVCMOS33 } [get_ports buzzer]

# ESP32 UART Transmitter (PMOD J16 - IO_2)
set_property -dict { PACKAGE_PIN T3 IOSTANDARD LVCMOS33 } [get_ports esp32_tx]

create_clock -period 41.667 -name sys_clk_pin -waveform {0.000 20.833} [get_ports clk_24mhz]