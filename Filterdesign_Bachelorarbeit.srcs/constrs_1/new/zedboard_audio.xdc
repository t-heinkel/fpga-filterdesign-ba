# timing constraints
create_clock -period 10.000 -name clk [get_ports clk]

#set_false_path -from [get_clocks clk_24] -to [get_clocks clk_100]
#set_false_path -from [get_clocks clk_100] -to [get_clocks clk_24]

# 100 mhz clock
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# 24 mhz clock to audio chip
set_property PACKAGE_PIN AB2 [get_ports AC_MCLK]
set_property IOSTANDARD LVCMOS33 [get_ports AC_MCLK]


# I2S transfers audio samples
# i2s data to ADAU1761
set_property PACKAGE_PIN Y8 [get_ports AC_GPIO0]
set_property IOSTANDARD LVCMOS33 [get_ports AC_GPIO0]

# i2s data from ADAU1761
set_property PACKAGE_PIN AA7 [get_ports AC_GPIO1]
set_property IOSTANDARD LVCMOS33 [get_ports AC_GPIO1]

# i2s bit clock from ADAU1761
set_property PACKAGE_PIN AA6 [get_ports AC_GPIO2]
set_property IOSTANDARD LVCMOS33 [get_ports AC_GPIO2]

# i2s l/r 48 khz toggling signal from ADAU1761 (sample clock)
set_property PACKAGE_PIN Y6 [get_ports AC_GPIO3]
set_property IOSTANDARD LVCMOS33 [get_ports AC_GPIO3]


# I2C Data Interface to ADAU1761 (for configuration)
set_property PACKAGE_PIN AB4 [get_ports AC_SCK]
set_property IOSTANDARD LVCMOS33 [get_ports AC_SCK]

set_property PACKAGE_PIN AB5 [get_ports AC_SDA]
set_property IOSTANDARD LVCMOS33 [get_ports AC_SDA]

set_property PACKAGE_PIN AB1 [get_ports AC_ADR0]
set_property IOSTANDARD LVCMOS33 [get_ports AC_ADR0]

set_property PACKAGE_PIN Y5 [get_ports AC_ADR1]
set_property IOSTANDARD LVCMOS33 [get_ports AC_ADR1]

# Button Pins for Effect Selection
# BTNL
set_property PACKAGE_PIN N15 [get_ports btnL]
set_property IOSTANDARD LVCMOS33 [get_ports btnL]

# BTNC
set_property PACKAGE_PIN P16 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

# BTNR
set_property PACKAGE_PIN R18 [get_ports btnR]
set_property IOSTANDARD LVCMOS33 [get_ports btnR]

# BTNU
set_property PACKAGE_PIN T18 [get_ports btnU]
set_property IOSTANDARD LVCMOS33 [get_ports btnU]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_wizard/inst/clkfbout_buf_clk_wiz_0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 1 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list sd_in_int]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list sd_out_int]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_clkfbout_buf_clk_wiz_0]
