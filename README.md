## c64bs

<pre>
"BS  1.*" is a 'new' operating system for the C64 - actually it patches
          the original one and has many more features.
          1) I have an ACIA 6551 at $d600 (above the SID) in my C64, so the
             normal RS232 routines have been exchanged by the 6551 ones.
             note that the 6551 has a bug if you use hardware handshake,
             disabling the outgoing of RTS/CTS also disables the receiver!
             You may loose characters and are warned
          2) in the now plenty of free space there is a Function-Key setting,
             and a Disk-Command-Line interface. You can load/save a programm
             in the directory (without removing "PRG") and standard file
             for load/save/shift-run-stop is IEC device 8. 
          3) I have an additional CBM IEEE488 (the parallel one) Interface on 
             the expansion port of my C64. Unfortunately the Cartridge ROM 
             copied itself to somewhere in $cxxx and completely disabled the 
             serial bus. No use for many programms and if you have two drives 
             - one parallel and one serial. So I removed the tape routines and
             replaced them with the IEEE488 routines. Now you can choose
             by a POKE (to ????). The IEEE488 routines don't look that well,
             I reassembled them automatically (see another of my tools) from
             the ROM (No not, copying copyrighted code ;-). Actually, this only
             works with the Commodore expansion, so everyone who has them
             should have the right to use this ROM) In the sources in 26080
             the default value for the map is loaded, change it to what you 
             want, a one means serial, zero is parallel, Bit 0 is Device 4,
             Bit 7 is device 10, Bit 8 is used to store the actual state.
          4) You can now use decimals like "$12ab" in hex, "&234" in octal
             and "%001010" in binary format. Some special keys for the
             screen editor have been added (Ctrl-Insert, Ctrl-Home and Ctrl-
             Crsr-Right)
          5) This one has some scroll options (try CTRL and CBM keys in 
             combination), a Hardcopy-routine (? as far as I see from the
             sources, my C64 is packed) and a screen-blanker?
          This description is for the latest version, 
          BS  1.22.S41 is only number 1) and 2).
          BS  1.25.S03 is a reengineering from 1.32, it only has ACIA routines,
                       F-keys, hex/octal/binariy ints, the @-Disk commands but
                       no tape. especially for a friend of mine who doesn't 
                       have the IEEE488.
          BS  1.32.S63 has 1) to 4)
          BS  1.33.S88 has all

	  BS  1.40.S89 has all except 1, but it has serial line routines
		       for a 16550A UART (with FIFO) instead.

          A ROM image for 1.31, 1.32 and 1.40 is included. The ROM images have
	  the UART/ACIA at $d600 and the TPI at $df00.
</pre>      

## How to use 
The C64 patches have quite some history, so everything looks a bit messy.
The newest version is 1.40 (of Feb 25, 1997) has the ACIA serial interface
routines replaced by UART 16550A routines.

To assemble the source "BS  1.40.S89,P" (C64 BASIC program) yourself, 
you have to have my 
[@ASS assembler](http://6502.org/users/andre/misc/index.html) at $7000 in memory (or change the
SYS statements in the source). In line 11090 you can change the address of the
UART in memory. I have it mapped above the SID, at $d600.
In line 12600 you can change the address of the TPI (Tri-Port-Interface)
for the Commodore IEEE488 interface. In line 26085 you can change the 
mapping of the IEC devices to parallel and serial bus. A 0 means parallel
IEEE488 bus, a 1 means serial IEC bus. Bit 0 is for device 4, bit 1 for device
5, and so on till bit 6 for device 10. Bit 7 must here be one; device 11
and above are always on the serial bus. If you don't have an IEEE488 interface,
leave TPI at $d600 and change the map value to $ff (i.e. all to serial bus).
You must have an UART in your computer to use this ROM!

The same applies for the version "BS  1.33.S88,P", which has the ACIA 
routines instead of the UART routines only. 

You can change the mapping of the IEC devices by POKE-ing a new MAP value (as 
described above) to $299.

## Archive descriptions
All files with a ".S??" at the end are source files for my selfwritten
6502 Assembler for the C64 (see directory "assembler"). They can be edited 
as a BASIC file and a RUN
makes them assemble, if you have my assembler in the computer's memory 
(at $7000).

## Archive descriptions
Note that the @ASS assembler used has a feature to print out a formatted listing
during assembly. Open a file for writing, then during the assembly run
in the .opt pseudo-opcode, redirect output to this opened file descriptor.
For an example see the Screenshot_assembly.png file

## Author

This is Copyright A.Fachat, for distributing use my own 
[License](MYCOPYING.ASC)

### Info: Andre Fachat, afachat@gmx.de

### Disclaimer 
  BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU
OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

These ROMs (esp. version 1.40) have not been tested very well. 
They surely contain bugs. You are warned.

The ROM images contain copyrighted code - i.e. they are patched C64 ROMs, 
copyrighted by CBM (or whatever remains of this company).
