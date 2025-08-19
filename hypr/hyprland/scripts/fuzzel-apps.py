#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path
import json
import configparser

def get_app_dirs():
    """
    Returns a list of directories where .desktop files are commonly found.
    """
    xdg_data_home = Path(os.environ.get("XDG_DATA_HOME", "~/.local/share")).expanduser()
    xdg_data_dirs = [
        Path(p) for p in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":")
    ]

    app_dirs = [
        xdg_data_home / "applications",
        xdg_data_home / "flatpak/exports/share/applications",
    ]
    app_dirs.extend([d / "applications" for d in xdg_data_dirs])
    app_dirs.extend([d / "flatpak/exports/share/applications" for d in xdg_data_dirs])
    # Add the flatpak system-wide directory
    app_dirs.append(Path("/var/lib/flatpak/exports/share/applications"))

    # Filter out directories that don't exist
    return [d for d in app_dirs if d.is_dir()]

def parse_desktop_file(file_path):
    """
    Parses a .desktop file and returns a dictionary of its properties.
    """
    parser = configparser.ConfigParser(interpolation=None)
    try:
        parser.read(file_path)

        entry = parser["Desktop Entry"]
        if entry.getboolean("NoDisplay", False):
            return None

        # The Exec key is required.
        if "Exec" not in entry:
            return None

        return {
            "name": entry.get("Name", "Unnamed"),
            "exec": entry.get("Exec").split(" ")[0], # Basic parsing of Exec
            "icon": entry.get("Icon", None),
        }
    except (configparser.Error, UnicodeDecodeError, FileNotFoundError):
        return None

def get_cache_file():
    """
    Returns the path to the cache file.
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
        if app_dir.stat().st_mtime > cache_mtime:
            return True

    return False

def find_applications(cache_file, app_dirs):
    """
    Finds all applications by searching for .desktop files.
    Caches the results.
    """
    if not is_cache_stale(cache_file, app_dirs):
        with open(cache_file, "r") as f:
            return json.load(f)

    apps = {}
    for app_dir in app_dirs:
        for desktop_file in app_dir.rglob("*.desktop"):
            app_info = parse_desktop_file(desktop_file)
            if app_info:
                # Use the app name as a key to avoid duplicates
                apps[app_info["name"]] = app_info

    app_list = list(apps.values())
    with open(cache_file, "w") as f:
        json.dump(app_list, f)

    return app_list


def main():
    """
    This script finds all .desktop files, parses them, caches the results,
    and then uses fuzzel to provide a searchable application launcher.
    """
    cache_file = get_cache_file()
    app_dirs = get_app_dirs()
    apps = find_applications(cache_file, app_dirs)

    # Create a mapping from name to exec command
    app_map = {app["name"]: app["exec"] for app in apps}

    # Format for fuzzel
    fuzzel_input = "\n".join(app_map.keys())

    try:
        fuzzel_proc = subprocess.run(
            ["fuzzel", "--dmenu"],
            input=fuzzel_input,
            capture_output=True,
            text=True,
            check=True
        )
        selected_app_name = fuzzel_proc.stdout.strip()

        if selected_app_name in app_map:
            exec_command = app_map[selected_app_name]
            # Execute the command in the background
            subprocess.Popen(exec_command.split(), start_new_session=True)

    except subprocess.CalledProcessError as e:
        # This will happen if the user closes fuzzel without selecting anything (e.g. pressing Esc)
        if e.returncode != 1:
            print(f"Fuzzel exited with error: {e}", file=sys.stderr)
            sys.exit(1)
    except FileNotFoundError:
        print("Error: fuzzel command not found. Is it installed and in your PATH?", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
