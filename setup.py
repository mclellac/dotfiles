#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import platform
import os
import sys
import subprocess
from pathlib import Path


from installer.colors import RED, GREEN, YELLOW, CYAN
from installer.setup_logs import setup_logging, log
from installer.files import copy_files_or_directories
from installer.ui import message_box
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

def print_banner() -> None:
    banner="""
                            ██████╗  ██████╗ ████████╗███████╗
                            ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
                            ██║  ██║██║   ██║   ██║   ███████╗
                            ██║  ██║██║   ██║   ██║   ╚════██║
                            ██████╔╝╚██████╔╝   ██║   ███████║
                            ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
    """
    print(banner)


    
def check_and_unset_alias() -> None:
    message_box("Checking if vim is aliased to nvim", color=CYAN)

    alias_check = run_command(["/bin/zsh", "-c", "alias"], check=False)
    if 'vim' in alias_check.stdout:
        print("vim is aliased to nvim. Unsetting the alias now.")
        run_command(["/bin/zsh", "-c", "unalias vim"])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-f", "--force", action="store_true", help="If set, it will override existing files")
    parser.add_argument("--config", default="config.yaml", help="Path to the YAML config file")
    parser.add_argument("--skip-vimplug", action="store_true", help="If set, do not update vim plugins.")
    parser.add_argument("--skip-zgen", action="store_true", help="If set, skip zgen updates.")
    parser.add_argument("--skip-shell-to-zsh", action="store_true", help="If set, skip changing shell to zsh.")
    return parser.parse_args()

def execute_tasks(tasks: list[dict[str, any]], current_dir: Path, args: argparse.Namespace) -> None:
    message_box("Copying dirs & files outlined in config.yaml", color=CYAN)
    for task in tasks:
        target = Path(task.get("target", "")).expanduser()
        source = current_dir / Path(task.get("source", "")).expanduser()

        copy_files_or_directories(str(target), str(source), args)

def main() -> None:
    args = parse_args()
    print_banner()
    setup_logging()
    check_and_unset_alias()

    config = load_config(args.config)
    tasks = [task for task in config.get("tasks", {}) if not task.get("os") or task.get("os") == platform.system().lower()]

    current_dir = Path(__file__).resolve().parent
    os.chdir(current_dir)

    # print(f"Tasks: {tasks} Current Dir: {current_dir} Args: {args}")
    execute_tasks(tasks, current_dir, args)

    errors = []

    message_box("Post Install Actions", color=YELLOW, use_bold=True)
    post_install_actions = [
        action_install_neovim_py,
        action_shell_to_zsh,
        lambda _, errors: action_gitconfig_secret(errors),
        lambda args, errors: action_zgen_update(args, errors),
    ]

    vim_executables = ["nvim", "vim"]

    for executable in vim_executables:
        action_vim_update(executable, args, errors)

    execute_post_install_actions(post_install_actions, args, errors)

    if errors:
        message_box(f"You have {len(errors):3d} warnings or errors -- check the logs!", color=YELLOW, use_bold=True)
        for action_title, error_message in errors:
            log(f"   [{action_title}] {error_message}", color=RED)
        log("\n")
    else:
        message_box("✔  You are all set! ", color=GREEN, use_bold=True)

    log(f"- Please restart the shell (e.g. {CYAN('`exec zsh`')}) if necessary.")
    log("\n\n", cr=False)

if __name__ == "__main__":
    main()
