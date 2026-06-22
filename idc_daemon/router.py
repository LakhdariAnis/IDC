import json
import subprocess
import sys
import traceback

_registry: dict[str, callable] = {}

context: dict = {"active_ws": None}


def register(type_str: str):
    def decorator(func):
        _registry[type_str] = func
        return func
    return decorator


async def dispatch(message_str: str, websocket, ctx: dict):
    try:
        data = json.loads(message_str)
    except json.JSONDecodeError:
        print(f"  Ignoring invalid JSON: {message_str}")
        return

    if not isinstance(data, dict):
        print(f"  Ignoring non-dict message")
        return

    msg_type = data.get("type")
    if not isinstance(msg_type, str):
        print(f"  Ignoring message without 'type' string field")
        return

    handler = _registry.get(msg_type)
    if handler is None:
        print(f"  Unknown message type '{msg_type}'")
        return

    payload = data.get("payload")
    if not isinstance(payload, dict):
        payload = {}

    try:
        await handler(payload, websocket, ctx)
    except Exception:
        print(f"  Error handling message type '{msg_type}':", file=sys.stderr)
        traceback.print_exc()


@register("ping")
async def _handle_ping(payload: dict, websocket, ctx: dict):
    await websocket.send(json.dumps({"type": "pong"}))


@register("clipboard_push")
async def _handle_clipboard_push(payload: dict, websocket, ctx: dict):
    text = payload.get("text", "")
    if not text:
        print("  Clipboard push — empty text, ignoring")
        return
    try:
        subprocess.run(["wl-copy"], input=text.encode(), check=True)
        print(f"  Clipboard received from phone ({len(text)} chars)")
    except FileNotFoundError:
        print("  Clipboard push failed: wl-copy not found (is wl-clipboard installed?)")
    except Exception as e:
        print(f"  Clipboard push failed: {e}")
