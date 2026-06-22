import asyncio
import threading

from discovery import serve_discovery
from connection_server import main as run_ws_server
from local_trigger import run_server as run_unix_server


async def main_async():
    ws_task = asyncio.create_task(run_ws_server())
    unix_task = asyncio.create_task(run_unix_server())
    await asyncio.gather(ws_task, unix_task)


def main():
    print("IDC Daemon starting...")

    stop_event = threading.Event()

    disc_thread = threading.Thread(
        target=serve_discovery,
        args=(stop_event,),
        daemon=True,
    )
    disc_thread.start()

    try:
        asyncio.run(main_async())
    except KeyboardInterrupt:
        pass
    finally:
        print("Shutting down both services...")
        stop_event.set()
        disc_thread.join(timeout=3)
        print("Done")


if __name__ == "__main__":
    main()
