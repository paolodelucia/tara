"""
Gives the charm your Queen's eduroam login over USB (once per board; it
survives reflashing). The board then joins eduroam by itself on campus, and
only ever sends the login to Queen's server (networkauth.queensu.ca).

Run (board plugged in, nothing else using its port):
    python send_eduroam.py            set or change the login
    python send_eduroam.py --forget   erase it from the board
    python send_eduroam.py COM7       if the board isn't found by itself

Your NetID password is typed in here, isn't shown, and isn't saved anywhere
on this computer.
"""

import getpass
import sys
import time

import serial
from serial.tools import list_ports

ESPRESSIF_VID = 0x303A


def find_port():
    for p in list_ports.comports():
        if p.vid == ESPRESSIF_VID:
            return p.device
    sys.exit("Couldn't find the board. Plug it in, close any serial monitor, "
             "or pass the port: python send_eduroam.py COM7")


def main():
    args = [a for a in sys.argv[1:] if a != "--forget"]
    port = args[0] if args else find_port()
    if "--forget" in sys.argv:
        command = "eduroam=forget"
    else:
        netid = input("NetID (e.g. 21abc4, without @queensu.ca): ").strip()
        password = getpass.getpass("NetID password (not shown): ")
        if not netid or not password or "\n" in password:
            sys.exit("Need both a NetID and a password.")
        command = f"eduroam={netid}:{password}"

    with serial.Serial(port, 115200, timeout=0.5) as ser:
        time.sleep(1)                      # let the board's console settle
        ser.reset_input_buffer()
        ser.write(f">{command}\n".encode())
        ser.flush()
        command = password = None          # drop the login from memory
        deadline = time.time() + 10
        while time.time() < deadline:
            line = ser.readline().decode(errors="replace").strip()
            if line.startswith("@eduroam"):
                print("Board says:", line)
                if " ok" in line:
                    print("Done. On campus the board now joins eduroam by itself.")
                    return
                sys.exit("The board didn't accept it.")
    sys.exit("No answer from the board in 10 s. Is the charm firmware with "
             "eduroam support on it?")


if __name__ == "__main__":
    main()
