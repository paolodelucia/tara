"""
Flashes the Muse gadget firmware (built by build.sh into firmware/) onto the
Waveshare board over USB, using esptool.

Run (board plugged in, Arduino's Serial Monitor closed):
    python flash.py            finds the board by itself
    python flash.py COM7       if it doesn't
    python flash.py --erase    wipe the whole flash first (first time coming
                               from Arduino firmware; also forgets the token,
                               pairing and Wi-Fi)

If it can't connect: hold BOOT, tap PWR, release BOOT, and run it again.
After it finishes, unplug and replug the board.
"""

import subprocess
import sys
from pathlib import Path

from serial.tools import list_ports

ESPRESSIF_VID = 0x303A
FIRMWARE = Path(__file__).parent / "firmware"


def find_port():
    for p in list_ports.comports():
        if p.vid == ESPRESSIF_VID:
            return p.device
    sys.exit("Couldn't find the board. Plug it in, or pass the port: python flash.py COM7")


def main():
    if not (FIRMWARE / "flash_args").exists():
        sys.exit("No firmware yet: run build.sh first (see README.md).")
    args = [a for a in sys.argv[1:] if a != "--erase"]
    port = args[0] if args else find_port()
    esptool = [sys.executable, "-m", "esptool", "--chip", "esp32s3", "-p", port, "-b", "460800"]
    if "--erase" in sys.argv:
        print(f"Erasing the whole flash on {port}...")
        if subprocess.call(esptool + ["--after", "no-reset", "erase-flash"]) != 0:
            sys.exit(1)
    print(f"Flashing the board on {port}...")
    sys.exit(subprocess.call(esptool + ["write-flash", "@flash_args"], cwd=FIRMWARE))


if __name__ == "__main__":
    main()
