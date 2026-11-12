"""
Gives the Muse gadget its SDK token over USB, so the token never sits in the
firmware or in a file. The board stores it, answers "@sdk_token ok" and
restarts. Needed once per board (it survives reflashing).

Run (board plugged in, nothing else using its port):
    python send_token.py            finds the board by itself
    python send_token.py COM7       if it doesn't

You paste the token when asked; it isn't shown or saved anywhere.
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
             "or pass the port: python send_token.py COM7")


def main():
    port = sys.argv[1] if len(sys.argv) > 1 else find_port()
    token = getpass.getpass("Paste your SDK token (starts with mgst_), then Enter: ").strip()
    if not token.startswith("mgst_"):
        sys.exit("That doesn't look like an SDK token (they start with mgst_).")

    with serial.Serial(port, 115200, timeout=0.5) as ser:
        time.sleep(1)                      # let the board's console settle
        ser.reset_input_buffer()
        ser.write(f">sdk_token={token}\n".encode())
        ser.flush()
        deadline = time.time() + 10
        while time.time() < deadline:
            line = ser.readline().decode(errors="replace").strip()
            if "@sdk_token" in line:
                print("Board says:", line.replace(token, "mgst_..."))
                if "ok" in line:
                    print("Done. The board restarts with the token; now pair it in the Muse app.")
                    return
                sys.exit("The board didn't accept it; check the token and try again.")
    sys.exit("No answer from the board in 10 s. Is the Muse firmware running on it?")


if __name__ == "__main__":
    main()
