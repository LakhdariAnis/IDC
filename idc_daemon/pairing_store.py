import json
from datetime import datetime, timezone
from pathlib import Path


_STORE_PATH = Path.home() / ".config" / "idc" / "paired_devices.json"


def load_paired_devices() -> dict:
    if not _STORE_PATH.exists():
        return {}
    with open(_STORE_PATH) as f:
        return json.load(f)


def is_paired(device_id: str) -> bool:
    return device_id in load_paired_devices()


def save_paired_device(device_id: str, device_name: str) -> None:
    _STORE_PATH.parent.mkdir(parents=True, exist_ok=True)
    devices = load_paired_devices()
    devices[device_id] = {
        "device_name": device_name,
        "paired_at": datetime.now(timezone.utc).isoformat(),
    }
    with open(_STORE_PATH, "w") as f:
        json.dump(devices, f, indent=2)
