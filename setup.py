#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import platform
import os
from pathlib import Path
from rich import print
from rich.console import Console
from rich.panel import Panel
from rich.theme import Theme

from installer.setup_logs import setup_logging, log
from installer.files import copy_files_or_directories
from installer.actions import (
    run_command,
    execute_post_install_actions,
    action_zgen_update,
    action_vim_update,
    action_install_neovim_py,
    action_shell_to_zsh,
    action_gitconfig_secret,
)
from installer.setup_config import load_config

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
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                                                                                ┃
    ┃            ██╗  ██╗ ██████╗ ██████╗  ██████╗███████╗███╗   ███╗                ┃
    ┃            ╚██╗██╔╝██╔═══██╗██╔══██╗██╔════╝██╔════╝████╗ ████║                ┃
    ┃             ╚███╔╝ ██║   ██║██████╔╝██║     ███████╗██╔████╔██║                ┃
    ┃             ██╔██╗ ██║   ██║██╔══██╗██║     ╚════██║██║╚██╔╝██║                ┃
    ┃            ██╔╝ ██╗╚██████╔╝██║  ██║╚██████╗███████║██║ ╚═╝ ██║                ┃
    ┃            ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝     ╚═╝                ┃   
    ┃                                                                                ┃
    ┃        ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗           ┃
    ┃        ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝           ┃
    ┃        ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗           ┃
    ┃        ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║           ┃
    ┃        ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║           ┃
    ┃        ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝           ┃
    ┃                                                                                ┃    
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
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
    return parser.parse_args()


def execute_tasks(
    tasks: list[dict], current_dir: Path, args: argparse.Namespace
) -> None:
    """Executes the tasks outlined in the config file."""
    console.print(Panel("Copying dirs & files outlined in config.yaml", style="cyan"))
    for task in tasks:
        target = Path(task.get("target", "")).expanduser()
        source = current_dir / Path(task.get("source", "")).expanduser()
        copy_files_or_directories(str(target), str(source), args)


def main() -> None:
    """Main entry point."""
    args = parse_args()
    print_banner()
    setup_logging()
    check_and_unset_alias()

    config = load_config(args.config)
    tasks = [
        task
        for task in config.get("tasks", {})
        if not task.get("os") or task.get("os") == platform.system().lower()
    ]

    current_dir = Path(__file__).resolve().parent
    os.chdir(current_dir)

    execute_tasks(tasks, current_dir, args)

    errors = []

    vim_executables = ["nvim", "vim"]
    for executable in vim_executables:
        action_vim_update(executable, args, errors, console=console)

    console.print(Panel("Post Install Actions", style="cyan"))

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
