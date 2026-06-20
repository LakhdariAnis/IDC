import json
import os
import socket
import uuid
from pathlib import Path


def load_or_create_pc_id() -> str:
    path = Path.home() / ".config" / "idc" / "pc_id.json"
    if path.exists():
        with open(path) as f:
            return json.load(f)["pc_id"]
    path.parent.mkdir(parents=True, exist_ok=True)
    pc_id = str(uuid.uuid4())
    with open(path, "w") as f:
        json.dump({"pc_id": pc_id}, f)
    return pc_id


def discovery_reply(pc_id: str) -> bytes:
    payload = {
        "name": socket.gethostname(),
        "ws_port": 58112,
        "pc_id": pc_id,
    }
    return json.dumps(payload).encode("utf-8")


def serve_discovery(stop_event=None) -> None:
    pc_id = load_or_create_pc_id()
    hostname = socket.gethostname()

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", 58111))
    sock.settimeout(1.0)

    print("Discovery listening on UDP :58111")

    try:
        while True:
            if stop_event and stop_event.is_set():
                break
            try:
                data, addr = sock.recvfrom(1024)
            except socket.timeout:
                continue

            try:
                msg = data.decode("utf-8")
            except UnicodeDecodeError:
                continue

            if msg != "IDC_DISCOVER":
                continue

            ip, port = addr
            sock.sendto(discovery_reply(pc_id), addr)
            print(f"Discovery ping from {ip}:{port} — replied as '{hostname}'")
    except KeyboardInterrupt:
        pass
    finally:
        sock.close()


def main() -> None:
    try:
        serve_discovery()
    except KeyboardInterrupt:
        print("Shutting down")


if __name__ == "__main__":
    main()
