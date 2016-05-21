from cmd import Cmd
import sys, os, subprocess
from rw_reg import *



class Prompt(Cmd):

    def do_hello(self, args):
        """Says hello. If you provide a name, it will greet you with it."""
        if len(args) == 0:
            name = 'stranger'
        else:
            name = args
        print "Hello, %s" % name


    def do_read(self, args):
        """Reads register. USAGE: read <register name>. OUTPUT <address> <mask> <permission> <name> <value>"""
        reg = getNode(args)
        if reg is not None: 
            address = reg.real_address
            if 'r' in str(reg.permission):
                print hex(address),'{0:#010x}'.format(reg.mask),reg.permission,'\t',reg.name,'\t',readReg(reg)
            elif reg.isModule: print 'This is a module!'
            else: print hex(address),'\t',reg.name,'\t','No read permission!' 
        else:
            print args,'not found!'

    
    def complete_read(self, text, line, begidx, endidx):
        tree = xml.parse(ADDRESS_TABLE_TOP)
        root = tree.getroot()[0]
        nodes = []
        vars = {}
        REGS = []
        makeTree(root,'',0x0,nodes,None,vars,False)
        for n in nodes:
            REGS.append(n.name)
        if not text:
            completions = REGS
        else:
            
            completions = [ f for f in REGS if f.startswith(text) ]
        return completions

    def do_write(self, args):
        """Writes register. USAGE: write <register name> <register value>"""
        arglist = args.split()
        if len(arglist)==2:
            reg = getNode(arglist[0])
            if reg is not None:
                try: value = parseInt(arglist[1])
                except: 
                    print 'Write Value must be a number!'
                    return
                address = reg.real_address
                print 'Register:',reg.name
                print 'Address:',hex(address)
                print 'Mask :','{0:#010x}'.format(reg.mask)
                print 'Value:','{0:#010x}'.format(value)
                if 'w' in str(reg.permission):
                    print writeReg(reg,value)
                else: print 'No write permission!'    
                
            else: print arglist[0],'not found!'
        else: print "Incorrect number of arguments!"

    def complete_write(self, text, line, begidx, endidx):
        tree = xml.parse(ADDRESS_TABLE_TOP)
        root = tree.getroot()[0]
        nodes = []
        vars = {}
        REGS = []
        makeTree(root,'',0x0,nodes,None,vars,False)
        for n in nodes:
            REGS.append(n.name)
        if not text:
            completions = REGS
        else:
            completions = [ f for f in REGS
                            if f.startswith(text) ]
        return completions

    def do_readGroup(self, args): #INEFFICIENT
        """Read all registers below node in register tree. USAGE: readGroup <register/node name> """
        node = getNode(args)
        if node is not None: 
            print 'NODE:',node.name
            kids = []
            getAllChildren(node, kids)
            print len(kids),'CHILDREN'
            for reg in kids: 
                if 'r' in str(reg.permission):
                    address = reg.address
                    address = address << 2
                    address = address + 0x64000000
                    print hex(address).rstrip('L'),reg.permission,'\t',tabPad(reg.name,7),readReg(reg)
        else: print args,'not found!'

    def complete_readGroup(self, text, line, begidx, endidx):
        tree = xml.parse(ADDRESS_TABLE_TOP)
        root = tree.getroot()[0]
        nodes = []
        vars = {}
        REGS = []
        makeTree(root,'',0x0,nodes,None,vars,False)
        for n in nodes:
            REGS.append(n.name)
        if not text:
            completions = REGS
        else:
            completions = [ f for f in REGS
                            if f.startswith(text) ]
        return completions

    def do_readFW(self, args):
        """Quick read of all FW-related registers"""
        for reg in getNodesContaining('STATUS.FW'):
            if 'r' in str(reg.permission):
                address = reg.address
                address = address << 2
                address = address + 0x64000000
                print hex(address),reg.permission,'\t',tabPad(reg.name,4),readReg(reg)

    def do_readKW(self, args):
        """Read all registers containing KeyWord. USAGE: readKW <KeyWord>"""
        if getNodesContaining(args) is not None and args!='':
            for reg in getNodesContaining(args):
                address = reg.address
                address = address << 2
                address = address + 0x64000000
                if 'r' in str(reg.permission):
                    print hex(address).rstrip('L'),reg.permission,'\t',tabPad(reg.name,7),readReg(reg)
                elif reg.isModule: print hex(address).rstrip('L'),reg.permission,'\t',tabPad(reg.name,7) #,'Module!'
                else: print hex(address).rstrip('L'),reg.permission,'\t',tabPad(reg.name,7) #,'No read permission!' 
        else: print args,'not found!'

    def do_readAll(self, args):
        """Read all registers with read-permission"""
        for reg in getNodesContaining(''):
            address = reg.address
            address = address << 2
            address = address + 0x64000000
            if 'r' in str(reg.permission):
                print hex(address).rstrip('L'),reg.permission,'\t',tabPad(reg.name,7),readReg(reg) 
            #elif reg.isModule: print reg.name,'is a module!'
            #else: print hex(address),'\t',tabPad(reg.name,7),'No read permission!' 

    def do_exit(self, args):
        """Exit program"""
        return True

    def do_readAddress(self, args):
        try: reg = getNodeFromAddress(parseInt(args))
        except: 
            print 'Error retrieving node.'
            return
        if reg is not None: 
            address = reg.real_address
            if 'r' in str(reg.permission):
                print hex(address),'{0:#010x}'.format(reg.mask),reg.permission,'\t',reg.name,'\t',readReg(reg)
            elif reg.isModule: print 'This is a module!'
            else: print hex(address),'\t',reg.name,'\t','No read permission!' 
        else:
            print args,'not found!' 

    def do_readRawAddress(self, args):
        """Not fully implemented. """
        try: print readRawAddress(args)
        except: print 'Error reading address.'
            

if __name__ == '__main__':
    parseXML()
    prompt = Prompt()
    prompt.prompt = 'CTP7 > '
    prompt.cmdloop('Starting Register Command Line Interface...')
