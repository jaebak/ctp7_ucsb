#!/bin/env python
from rw_reg import *
from mcs import *
from time import *
import array
import struct

SLEEP_BETWEEN_COMMANDS=0.1
DEBUG=False
CTP7HOSTNAME = "eagle33"

class Colors:            
    WHITE   = '\033[97m' 
    CYAN    = '\033[96m' 
    MAGENTA = '\033[95m' 
    BLUE    = '\033[94m' 
    YELLOW  = '\033[93m' 
    GREEN   = '\033[92m' 
    RED     = '\033[91m' 
    ENDC    = '\033[0m'  

REG_CTP7_BOARD_ID = None
REG_OH1_FW = None
REG_OH1_VFAT_MASK = None
REG_VFAT_CONTROL_REG = None

def main():

    parseXML()

    writeReg(getNode("GEM_AMC.GEM_SYSTEM.VFAT3.USE_OH_V3B_MAPPING"), 1)

    for i in range(0, 9):
        writeReg(getNode("GEM_AMC.GEM_SYSTEM.VFAT3.V3B_FPGA_TX_0_BITSLIP"), i)
        for j in range(0, 9):
            writeReg(getNode("GEM_AMC.GEM_SYSTEM.VFAT3.V3B_FPGA_TX_1_BITSLIP"), j)
            for k in range(0,5):
                value = readReg(getNode("GEM_AMC.OH.OH1.CONTROL.LOOPBACK.DATA"))
                print("for elink 0 tx slip = %d and elink 1 tx slip = %d, read back value = %s" % (i, j, value))
                if (value != 'Bus Error'):
                    printRed("========>>>>>>>>> YESSSS, this WORKS!!! <<<<<<<<<<<=============")

def checkStatus():
    rxReady       = parseInt(readReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.STATUS.READY')))
    criticalError = parseInt(readReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.STATUS.CRITICAL_ERROR')))
    return (rxReady == 1) and (criticalError == 0)

def check_bit(byteval,idx):
    return ((byteval&(1<<idx))!=0);

def debug(string):
    if DEBUG:
        print('DEBUG: ' + string)

def debugCyan(string):
    if DEBUG:
        printCyan('DEBUG: ' + string)

def heading(string):                                                                    
    print Colors.BLUE                                                             
    print '\n>>>>>>> '+str(string).upper()+' <<<<<<<'
    print Colors.ENDC                   
                                                      
def subheading(string):                         
    print Colors.YELLOW                                        
    print '---- '+str(string)+' ----',Colors.ENDC                    
                                                                     
def printCyan(string):                                                
    print Colors.CYAN                                    
    print string, Colors.ENDC                                                                     
                                                                      
def printRed(string):                                                                                                                       
    print Colors.RED                                                                                                                                                            
    print string, Colors.ENDC                                           

def hex(number):
    if number is None:
        return 'None'
    else:
        return "{0:#0x}".format(number)

def binary(number, length):
    if number is None:
        return 'None'
    else:
        return "{0:#0{1}b}".format(number, length + 2)

if __name__ == '__main__':
    main()
