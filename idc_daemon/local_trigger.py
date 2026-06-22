import asyncio
import json
import os

import router
from clipboard import read_pc_clipboard


async def _handle_client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
    print("  Unix socket trigger received")

    ws = router.context.get("active_ws")
    if ws is None:
        print("  No phone connected, clipboard not sent")
        writer.close()
        return

    text = read_pc_clipboard()
    if text is None:
        print("  Clipboard read failed, nothing sent")
        writer.close()
        return

    msg = json.dumps({"type": "clipboard_push", "payload": {"text": text}})
    await ws.send(msg)
    print(f"  Clipboard sent to phone ({len(text)} chars)")

    writer.close()


async def run_server():
    socket_path = f"/run/user/{os.getuid()}/idc/clipboard.sock"
    sock_dir = os.path.dirname(socket_path)

    os.makedirs(sock_dir, exist_ok=True)

    if os.path.exists(socket_path):
        os.unlink(socket_path)

    server = await asyncio.start_unix_server(_handle_client, socket_path)
    os.chmod(socket_path, 0o600)

    print(f"Unix socket server listening at {socket_path}")

    async with server:
        await server.serve_forever()
