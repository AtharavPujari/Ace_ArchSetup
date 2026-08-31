#!/usr/bin/env python3
import os
import time
import json
import subprocess

def get_cursor_pos():
    try:
        res = subprocess.check_output(["hyprctl", "cursorpos"], text=True).strip()
        x, y = map(int, res.split(","))
        return x, y
    except Exception:
        return None, None

def get_monitors():
    try:
        res = subprocess.check_output(["hyprctl", "monitors", "-j"], text=True)
        return json.loads(res)
    except Exception:
        return []

def get_active_window():
    try:
        res = subprocess.check_output(["hyprctl", "activewindow", "-j"], text=True)
        if res.strip():
            return json.loads(res)
    except Exception:
        pass
    return None

def move_window(addr, target_ws):
    addr_str = addr if addr.startswith("0x") else f"0x{addr}"
    cmd = f'hl.dsp.window.move({{ window = "address:{addr_str}", workspace = "{target_ws}", follow = true }})'
    try:
        subprocess.run(["hyprctl", "dispatch", cmd], check=False)
    except Exception as e:
        pass

def main():
    cooldown = 0
    flag_file = "/tmp/hypr_super_active"
    while True:
        time.sleep(0.08)

        # Require Super key to be active
        if not os.path.exists(flag_file):
            continue

        now = time.time()
        if now < cooldown:
            continue

        x, y = get_cursor_pos()
        if x is None:
            continue

        monitors = get_monitors()
        if not monitors:
            continue

        active_mon = None
        for m in monitors:
            mx = m.get("x", 0)
            mw = m.get("width", 1920)
            if mx <= x < mx + mw:
                active_mon = m
                break

        if not active_mon:
            active_mon = monitors[0]

        mx = active_mon.get("x", 0)
        mw = active_mon.get("width", 1920)

        left_edge = mx + 5
        right_edge = mx + mw - 5

        if x <= left_edge:
            win = get_active_window()
            if win and win.get("address"):
                move_window(win["address"], "-1")
                cooldown = time.time() + 0.65
        elif x >= right_edge:
            win = get_active_window()
            if win and win.get("address"):
                move_window(win["address"], "+1")
                cooldown = time.time() + 0.65

if __name__ == "__main__":
    main()
