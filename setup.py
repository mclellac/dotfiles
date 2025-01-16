#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import os
import platform
from pathlib import Path
from typing import Dict, List, Optional

from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress
from rich.theme import Theme

from installer.actions import (
    action_gitconfig_secret,
    action_install_neovim_py,
    action_shell_to_zsh,
    action_vim_update,
    action_zgen_update,
    execute_post_install_actions,
    run_command,
)
from installer.files import copy_files_or_directories
from installer.packages import enable_copr_repo, install_packages, is_package_installed
from installer.setup_config import load_config
from installer.setup_logs import log, setup_logging

# Define the custom theme
custom_theme = Theme(
    {
        "info": "cyan",
        "warning": "yellow",
        "error": "red",
        "success": "green",
    }
)

# Initialize rich console with the custom theme
console = Console(theme=custom_theme)


def print_banner() -> None:
    """Prints the banner."""
    banner = """
  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃                                                                           ┃
  ┃       ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗       ┃
  ┃       ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝       ┃
  ┃       ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗       ┃
  ┃       ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║       ┃
  ┃       ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║       ┃
  ┃       ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝       ┃
  ┃                                                                           ┃    
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
    """
    print(banner)


def check_and_unset_alias() -> None:
    """Checks and unsets the alias if 'vim' is aliased to 'nvim'."""
    alias_check = run_command(["/bin/zsh", "-c", "alias"], check=False)
    if "vim" in alias_check.stdout:
        console.print("vim is aliased to nvim. Unsetting the alias now.")


def parse_args() -> argparse.Namespace:
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        "-f", "--force", action="store_true", help="Override existing files"
    )
    parser.add_argument(
        "--config", default="config.yaml", help="Path to the YAML config file"
    )
    parser.add_argument(
        "--skip-vimplug", action="store_true", help="Skip vim plugin updates"
    )
    parser.add_argument("--skip-zgen", action="store_true", help="Skip zgen updates")
    parser.add_argument(
        "--skip-shell-to-zsh", action="store_true", help="Skip changing shell to zsh"
    )
    parser.add_argument(
        "--skip-packages", action="store_true", help="Skip package installation"
    )
    return parser.parse_args()


def execute_tasks(
    tasks: List[Dict[str, Optional[str]]], current_dir: Path, args: argparse.Namespace
) -> None:
    """Executes the tasks outlined in the config file."""
    console.print(
        Panel("Copying dirs & files outlined in config.yaml", style="cyan", width=80)
    )
    for task in tasks:
        target = Path(task.get("target", "")).expanduser()
        source = current_dir / Path(task.get("source", "")).expanduser()
        copy_files_or_directories(str(target), str(source), args)


def create_empty_file(filename: str) -> None:
    """Create an empty file with the given filename in the user's home directory."""
    home_dir = os.path.expanduser("~")
    file_path = os.path.join(home_dir, filename)

    if os.path.exists(file_path):
        console.print(f"File already exists at {home_dir}/{filename}. Skipping...")
    else:
        try:
            with open(file_path, "w"):
                pass  # Create the empty file
            console.print(f"Empty file created successfully at {home_dir}/{filename}.")
        except Exception as e:
            console.print(f"Error occurred while creating empty file '{filename}': {e}")


def main() -> None:
    """Main entry point."""
    args = parse_args()
    print_banner()
    setup_logging()
    check_and_unset_alias()

    config = load_config(args.config)

    # Ensure tasks are a list of dictionaries
    tasks = [
        task
        for task in config.get("tasks", [])  # Ensure it defaults to a list
        if not task.get("os") or task.get("os") == platform.system().lower()
    ]

    if not args.skip_packages:
        # Package installer
        console.print(
            Panel(
                "Installing packages with package manager & pip", style="cyan", width=80
            )
        )

        current_os = None

        try:
            run_command(["brew", "--version"], check=True, timeout=30)
            current_os = "darwin"
        except FileNotFoundError:
            try:
                import distro

                current_os = distro.id().lower()
            except ImportError:
                console.print(
                    "[bold red]Error:[/bold red] Unable to determine the operating system."
                )
                return

        if current_os in config:
            os_config = config[current_os]
            dnf_packages = os_config.get("dnf", [])
            pacman_packages = os_config.get("pacman", [])
            apt_packages = os_config.get("apt", [])
            brew_packages = os_config.get("brew", [])
            pip_packages = os_config.get("pip-packages", [])
            copr_repo = os_config.get("copr-repo", {}).get("name")

            if current_os == "fedora":
                create_empty_file(".zsh.gnu")
                create_empty_file(".zprivate")
                if copr_repo:
                    enable_copr_repo(copr_repo)
                with Progress() as progress:
                    task = progress.add_task(
                        "[cyan]Checking package installation...",
                        total=len(dnf_packages),
                    )
                    for pkg in dnf_packages:
                        is_package_installed(pkg, "dnf")
                        progress.update(task, advance=1, description=f"Checking {pkg}")
                install_packages(dnf_packages, "dnf")
            elif current_os == "arch":
                create_empty_file(".zsh.gnu")
                create_empty_file(".zprivate")
                with Progress() as progress:
                    task = progress.add_task(
                        "[cyan]Checking package installation...",
                        total=len(pacman_packages),
                    )
                    for pkg in pacman_packages:
                        is_package_installed(pkg, "pacman")
                        progress.update(task, advance=1, description=f"Checking {pkg}")
                install_packages(pacman_packages, "pacman")
            elif current_os in ["debian", "kali", "ubuntu"]:
                create_empty_file(".zsh.gnu")
                create_empty_file(".zprivate")
                with Progress() as progress:
                    task = progress.add_task(
                        "[cyan]Checking package installation...",
                        total=len(apt_packages),
                    )
                    for pkg in apt_packages:
                        is_package_installed(pkg, "apt")
                        progress.update(task, advance=1, description=f"Checking {pkg}")
                install_packages(apt_packages, "apt")
            elif current_os == "darwin":
                create_empty_file(".zsh.osx")
                create_empty_file(".zprivate")
                with Progress() as progress:
                    task = progress.add_task(
                        "[cyan]Checking package installation...",
                        total=len(brew_packages),
                    )
                    for pkg in brew_packages:
                        is_package_installed(pkg, "homebrew")
                        progress.update(task, advance=1, description=f"Checking {pkg}")
                install_packages(brew_packages, "homebrew")

        install_packages(pip_packages, "pip")

    current_dir = Path(__file__).resolve().parent
    os.chdir(current_dir)

    execute_tasks(tasks, current_dir, args)

    errors = []

    console.print(Panel("Post Install Actions", style="magenta", width=80))

    vim_executables = ["nvim", "vim"]
    for executable in vim_executables:
        action_vim_update(executable, args, errors, console=console)

    post_install_actions = [
        (action_install_neovim_py, [args]),
        (action_shell_to_zsh, [args]),
        (action_gitconfig_secret, [args]),
        (action_zgen_update, [args]),
    ]

    execute_post_install_actions(post_install_actions, errors, console=console)

    log(
        "- Please restart the shell (e.g. `exec zsh`) if necessary.",
        style="cyan",
        console=console,
    )


if __name__ == "__main__":
    main()
