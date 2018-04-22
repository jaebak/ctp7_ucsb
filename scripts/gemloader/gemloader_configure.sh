#!/bin/sh

#LOAD_BIT_FILE=/mnt/persistent/texas/oh_fw/evka_ohv3a_test0.bit
LOAD_BIT_FILE=/mnt/persistent/texas/oh_fw/OH-20180306-3.1.0.B.bit
#LOAD_BIT_FILE=/mnt/persistent/texas/oh_fw/OH-20180223-3.0.10.A.bit

echo "Loading $LOAD_BIT_FILE"
gemloader load $LOAD_BIT_FILE
#/mnt/persistent/texas/tamu/gemloader/gemloader_clear_header.sh

mpoke 0x6a000000 1       #enable the loader fw core
#mpoke 0x6a000004 7694183 #number of bytes to load -- OTMB mez (v6 190T)
mpoke 0x6a000004 5465074 #number of bytes to load -- OHv3a (v6 130T)
#mpoke 0x6a000004 5465091 #number of bytes to load -- OHv3b (v6 130T)
