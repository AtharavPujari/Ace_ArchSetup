#!/usr/bin/env python3
import os
import time
import json
import socket
import threading
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

def pack_workspaces():
    """
    Shifts windows on higher workspaces down to fill any empty workspace gaps,
    ensuring workspaces are strictly contiguous (1, 2, 3...) starting from 1 with no empty gaps.
    """
    try:
        res = subprocess.check_output(["hyprctl", "clients", "-j"], text=True)
        clients = json.loads(res)
        ws_map = {}
        for c in clients:
            ws = c.get("workspace", {})
            ws_id = ws.get("id")
            if ws_id and ws_id > 0:
                if ws_id not in ws_map:
                    ws_map[ws_id] = []
                ws_map[ws_id].append(c)

        if not ws_map:
            return

        sorted_ws_ids = sorted(ws_map.keys())
        has_gap = any(actual != idx for idx, actual in enumerate(sorted_ws_ids, start=1))

        if has_gap:
            active_win = get_active_window()
            active_addr = active_win.get("address") if active_win else None

            for idx, actual_ws_id in enumerate(sorted_ws_ids, start=1):
                if actual_ws_id != idx:
                    for win in ws_map[actual_ws_id]:
                        addr = win.get("address")
                        if addr:
                            addr_str = addr if addr.startswith("0x") else f"0x{addr}"
                            cmd = f'hl.dsp.window.move({{ window = "address:{addr_str}", workspace = "{idx}", follow = false }})'
                            subprocess.run(["hyprctl", "dispatch", cmd], check=False)

            if active_addr:
                curr_active = get_active_window()
                if curr_active and curr_active.get("workspace"):
                    ws_target = curr_active["workspace"].get("id")
                    if ws_target:
                        subprocess.run(["hyprctl", "dispatch", f"hl.dsp.focus({{ workspace = {ws_target} }})"], check=False)
    except Exception:
        pass

def move_window(addr, target_ws):
    addr_str = addr if addr.startswith("0x") else f"0x{addr}"
    cmd = f'hl.dsp.window.move({{ window = "address:{addr_str}", workspace = "{target_ws}", follow = true }})'
    try:
        subprocess.run(["hyprctl", "dispatch", cmd], check=False)
        time.sleep(0.05)
        pack_workspaces()
    except Exception:
        pass

def socket_listener():
    """
    Listens to Hyprland IPC socket2 events in real time.
    When windows close, open, or move, instantly packs workspaces.
    """
    while True:
        try:
            sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
            xdg = os.environ.get("XDG_RUNTIME_DIR")
            if not sig or not xdg:
                time.sleep(2)
                continue
            sock_path = f"{xdg}/hypr/{sig}/.socket2.sock"

            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(sock_path)
            buffer = ""
            while True:
                data = s.recv(4096)
                if not data:
                    break
                buffer += data.decode("utf-8", errors="ignore")
                while "\n" in buffer:
                    line, buffer = buffer.split("\n", 1)
                    line = line.strip()
                    if line:
                        event = line.split(">>")[0]
                        if event in ("closewindow", "openwindow", "movewindow", "destroywindow"):
                            time.sleep(0.02)
                            pack_workspaces()
            s.close()
        except Exception:
            time.sleep(1)

def main():
    # Initial packing on daemon start
    pack_workspaces()

    # Start IPC socket listener thread
    t = threading.Thread(target=socket_listener, daemon=True)
    t.start()

    cooldown = 0
    flag_file = "/tmp/hypr_super_active"

    while True:
        time.sleep(0.08)
        now = time.time()

        # Require Super key to be active for edge window dragging
        if not os.path.exists(flag_file):
            continue

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
