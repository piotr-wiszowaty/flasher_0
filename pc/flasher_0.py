#!/usr/bin/env python3

import argparse
import re
import serial
import sys

parser = argparse.ArgumentParser()
parser.add_argument("-a", "--start-address", metavar="NUM", default="0")
parser.add_argument("-d", "--device", metavar="PATH", default="/dev/ttyUSB0")
parser.add_argument("-e", "--echo", action="store_true", default=False)
parser.add_argument("-f", "--file", metavar="FILE")
parser.add_argument("-s", "--size", metavar="NUM", default="65536")
parser.add_argument("operation", choices=["read", "write", "erase"])
args = parser.parse_args()

try:
    if args.start_address.startswith("0x"):
        start = int(args.start_address[2:], 16)
    else:
        start = int(args.start_address)
except ValueError:
    sys.stderr.write(f"invalid address: {args.start_address}\n")
    sys.exit(1)
try:
    if args.size.startswith("0x"):
        size = int(args.size[2:], 16)
    else:
        size = int(args.size)
except ValueError:
    sys.stderr.write(f"invalid size: {args.size}\n")
    sys.exit(1)

uart = serial.Serial(args.device, baudrate=1000000, xonxoff=0, rtscts=0)

def tx(msg):
    data = msg.encode("ascii")
    uart.write(data)
    resp = uart.read(len(data)).decode()
    if args.echo: print(resp, end="")

uart.write(b"\n")
if (l := uart.readline().decode()) != "  ok.\n":
    print("unexpected:", l)
    sys.exit(1)

if args.operation == "read":
    tx(f"{start} {size} dump\n")
    uart.readline()
    print()
    f = open(args.file, "wb") if args.file else None
    for i in range(0, size, 32):
        l = uart.readline().decode()
        print(l, end="")
        if f:
            m = re.match("([\[][0-9a-fA-F]{5,8}[\]] )?([0-9a-fA-F]{64}).*", l)
            s = m.group(2)
            data = bytes([int(s[2*i:2*(i+1)], 16) for i in range(len(s)//2)])
            f.write(data)
    if f: f.close()
elif args.operation == "write":
    if args.file is None:
        sys.stderr.write("missing argument: file\n")
        sys.exit(1)
    with open(args.file, "rb") as f:
        data = f.read()
    for sector in range(0, len(data), 4096):
        tx(f"${start+sector:X} prog\n")
        print(uart.read(1).decode())
        for i in range(0, 4096, 32):
            chunk = data[sector+i:sector+i+32].hex().upper()
            tx(chunk + "\n")
            uart.readline()
            print()
        print(uart.readline().decode(), end="")
elif args.operation == "erase":
    tx("erase\n")

uart.close()
