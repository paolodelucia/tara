"""
Records the charm's log to a file, so a Wi-Fi problem somewhere else (say,
eduroam on campus) can be looked at later. Asks the board for its eduroam
login status and charge current first, then logs everything it prints.

Run (board plugged into this laptop, nothing else using its port):
    python capture_log.py              2 minutes
    python capture_log.py 300          5 minutes
    python capture_log.py 120 COM7     if the board isn't found by itself

Then turn the board on or let it try to join Wi-Fi. The file is saved here as
log-YYYYMMDD-HHMM.txt. Your password is never in it (the board never prints
it), and SDK tokens are blanked out.
"""

import re
import sys
import time
from datetime import datetime
from pathlib import Path

import serial
from serial.tools import list_ports

ESPRESSIF_VID = 0x303A
# Lines worth showing live; everything goes into the file regardless.
INTERESTING = re.compile(r"eduroam|wifi|wpa|eap|tls|cert|reason|disconnect|joining|got IP|"
                         r"@charge|@eduroam|error|fail", re.IGNORECASE)
TOKEN = re.compile(r"mgst_[A-Za-z0-9_\-]+")


def find_port():
    for p in list_ports.comports():
        if p.vid == ESPRESSIF_VID:
            return p.device
    return None


def open_port(port):
    s = serial.Serial()
    s.port, s.baudrate, s.timeout = port, 115200, 0.2
    s.dtr = s.rts = False          # don't reset the board by opening the port
    s.open()
    return s


def main():
    args = sys.argv[1:]
    seconds = int(args[0]) if args and args[0].isdigit() else 120
    port = next((a for a in args if a.upper().startswith("COM")), None) or find_port()
    if not port:
        sys.exit("Couldn't find the board. Plug it in, close any serial monitor, "
                 "or pass the port: python capture_log.py 120 COM7")

    out = Path(__file__).parent / f"log-{datetime.now():%Y%m%d-%H%M}.txt"
    print(f"Recording {port} for {seconds} s to {out.name}. Turn the board on or replug it now.")
    asked = False
    end = time.time() + seconds
    ser = None
    with open(out, "w", encoding="utf-8") as f:
        while time.time() < end:
            if ser is None:
                try:
                    ser = open_port(port)
                except serial.SerialException:
                    time.sleep(0.05)       # the port vanishes while the board restarts
                    continue
                if not asked:
                    time.sleep(0.5)
                    ser.write(b">eduroam=status\n>charge\n")
                    asked = True
            try:
                raw = ser.readline()
            except serial.SerialException:
                ser.close()
                ser = None
                continue
            if not raw:
                continue
            line = TOKEN.sub("mgst_[hidden]", raw.decode(errors="replace").rstrip())
            f.write(f"{datetime.now():%H:%M:%S} {line}\n")
            f.flush()
            if INTERESTING.search(line):
                print(line[:200])
    print(f"Done. Send {out} to Claude.")


if __name__ == "__main__":
    main()
