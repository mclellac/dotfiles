#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path
import json
import configparser
import shlex
import shutil


def get_app_dirs():
    """
    Returns a list of directories where .desktop files are commonly found.
    """
    xdg_data_home = Path(os.environ.get("XDG_DATA_HOME", "~/.local/share")).expanduser()
    xdg_data_dirs = [
        Path(p)
        for p in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(
            ":"
        )
    ]

    app_dirs = [
        xdg_data_home / "applications",
        xdg_data_home / "flatpak/exports/share/applications",
    ]
    app_dirs.extend([d / "applications" for d in xdg_data_dirs])
    app_dirs.extend([d / "flatpak/exports/share/applications" for d in xdg_data_dirs])
    app_dirs.append(Path("/var/lib/flatpak/exports/share/applications"))

    return [d for d in app_dirs if d.is_dir()]


def parse_desktop_file(file_path):
    """
    Parses a .desktop file and returns a dictionary of its properties.
    """
    parser = configparser.ConfigParser(interpolation=None)
    try:
        parser.read(file_path, encoding="utf-8")
        entry = parser["Desktop Entry"]

        if entry.getboolean("NoDisplay", False) or "Exec" not in entry:
            return None

        exec_cmd = entry.get("Exec")
        # Remove Desktop Entry Specification field codes like %f, %U, etc.
        exec_parts = [
            part for part in shlex.split(exec_cmd) if not part.startswith("%")
        ]

        # Heuristic to simplify gapplication launch commands
        if (
            len(exec_parts) == 3
            and exec_parts[0] == "gapplication"
            and exec_parts[1] == "launch"
        ):
            app_id = exec_parts[2]
            simple_name = app_id.split(".")[-1].lower()
            exec_cmd = (
                simple_name if shutil.which(simple_name) else " ".join(exec_parts)
            )
        else:
            exec_cmd = " ".join(exec_parts)

        return {
            "name": entry.get("Name", "Unnamed"),
            "exec": exec_cmd,
            "terminal": entry.getboolean("Terminal", False),
            "icon": entry.get("Icon", None),
        }
    except (configparser.Error, UnicodeDecodeError, FileNotFoundError):
        return None


def get_cache_file():
    """
    Returns the path to the application cache file.
    """
    xdg_cache_home = Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser()
    cache_dir = xdg_cache_home / "fuzzel-apps"
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir / "apps.json"


def is_cache_stale(cache_file, app_dirs):
    """
    Checks if the cache is stale by comparing modification times.
    """
    if not cache_file.exists():
        return True

    cache_mtime = cache_file.stat().st_mtime
    for app_dir in app_dirs:
        if app_dir.exists() and app_dir.stat().st_mtime > cache_mtime:
            return True
    return False


def find_applications(cache_file, app_dirs):
    """
    Finds all applications by searching for .desktop files and caches the results.
    """
    if not is_cache_stale(cache_file, app_dirs):
        with open(cache_file, "r") as f:
            return json.load(f)

    apps = {}
    for app_dir in app_dirs:
        for desktop_file in app_dir.rglob("*.desktop"):
            app_info = parse_desktop_file(desktop_file)
            if app_info:
                apps[app_info["name"]] = app_info

    app_list = list(apps.values())
    with open(cache_file, "w") as f:
        json.dump(app_list, f, indent=2)
    return app_list


def main():
    """
    Finds .desktop files, caches them, and uses fuzzel to launch the selected application via hyprctl.
    """
    cache_file = get_cache_file()
    app_dirs = get_app_dirs()
    apps = find_applications(cache_file, app_dirs)

    # Create a mapping from the app name to its full data dictionary
    app_map = {app["name"]: app for app in apps}
    fuzzel_input = "\n".join(sorted(app_map.keys()))

    try:
        fuzzel_proc = subprocess.run(
            ["fuzzel", "--dmenu"],
            input=fuzzel_input,
            capture_output=True,
            text=True,
            check=True,
        )
        selected_app_name = fuzzel_proc.stdout.strip()

        if selected_app_name in app_map:
            app_info = app_map[selected_app_name]
            exec_command = app_info["exec"]

            # If the app requires a terminal, wrap the command
            if app_info["terminal"]:
                terminal = os.environ.get("TERMCMD", "kitty")
                final_command = f"{terminal} {exec_command}"
            else:
                final_command = exec_command

            # Use hyprctl to dispatch the exec command for better integration
            subprocess.Popen(
                ["hyprctl", "dispatch", "exec", final_command],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

    except subprocess.CalledProcessError as e:
        # Fuzzel exits with code 1 when the user presses Esc; ignore it.
        if e.returncode != 1:
            print(f"Fuzzel exited with error: {e}", file=sys.stderr)
            sys.exit(1)
    except FileNotFoundError:
        print("Error: `fuzzel` or `hyprctl` command not found.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
