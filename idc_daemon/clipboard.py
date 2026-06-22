import subprocess


def read_pc_clipboard() -> str | None:
    try:
        result = subprocess.run(
            ["wl-paste"],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except FileNotFoundError:
        print("  Clipboard read failed: wl-paste not found (is wl-clipboard installed?)")
        return None
    except Exception as e:
        print(f"  Clipboard read failed: {e}")
        return None

    if result.returncode != 0:
        print(f"  Clipboard read failed: wl-paste returned exit code {result.returncode}")
        return None

    text = result.stdout.strip()
    if not text:
        print("  Clipboard is empty")
        return None

    return text
