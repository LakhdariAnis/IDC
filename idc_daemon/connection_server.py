import asyncio
import json
import sys
import traceback

import websockets
from websockets.exceptions import ConnectionClosed

from pairing_store import is_paired, save_paired_device


async def _handle(websocket):
    try:
        remote = websocket.remote_address
        print(f"New connection from {remote[0]}:{remote[1]}")

        raw = await asyncio.wait_for(websocket.recv(), timeout=30)
    except asyncio.TimeoutError:
        await websocket.close()
        return
    except ConnectionClosed:
        return
    except Exception:
        print(f"Connection handler error before handshake:", file=sys.stderr)
        traceback.print_exc()
        return

    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        await websocket.close()
        return

    if (
        not isinstance(data, dict)
        or not isinstance(data.get("device_id"), str)
        or not isinstance(data.get("device_name"), str)
        or not data["device_id"]
        or not data["device_name"]
    ):
        await websocket.close()
        return

    device_id = data["device_id"]
    device_name = data["device_name"]

    print(f"  Handshake from '{device_name}' ({device_id})")

    if is_paired(device_id):
        print(f"  Already paired — accepted")
    else:
        print(f"  New device — auto-accepted")
        save_paired_device(device_id, device_name)

    await websocket.send(json.dumps({"status": "accepted"}))
    print("  Sent accepted response, entering heartbeat loop")

    try:
        async for message in websocket:
            if message == "ping":
                await websocket.send("pong")
    except ConnectionClosed:
        pass
    except Exception:
        print(f"  Connection handler error during heartbeat:", file=sys.stderr)
        traceback.print_exc()

    print(f"  Disconnected")


async def main():
    print("Connection server listening on WS :58112")
    async with websockets.serve(_handle, "0.0.0.0", 58112):
        await asyncio.Future()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Shutting down")
