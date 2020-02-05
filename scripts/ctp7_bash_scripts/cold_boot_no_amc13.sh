#!/bin/sh

echo "CTP7 Virtex-7 cold boot in progress..."

echo "Configuring reference clocks..."

# First initialize ref clocks before loading the V7 firmware (160 MHz refclk)
clockinit clkA_125in_320p64_160p32_out.txt clkA_125in_320p64_160p32_out.txt B1 A1 A1 B1

sleep 1

false
RETVAL=$?

while [ $RETVAL -ne 0 ]
do
    v7load gem_ctp7_no_amc13.bit
    RETVAL=$?
done

# Disable Opto TX Lasers
/bin/txpower enable

# Configure GTHs in loopback mode
sh gth_config_opto.sh

# GTH channel reset procedure
sh gth_reset.sh

#Print gth status register
sh gth_status.sh

