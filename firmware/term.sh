#!/bin/sh

if [ -n "$1" ]; then
	baud=$1
else
	baud=1000000
fi

picocom -b $baud /dev/ttyUSB0 --imap lfcrlf,crcrlf --omap delbs,crlf --flow n --send-cmd "xfr -c -e -s -I $HOME/include/ARM/STM32F05x"
