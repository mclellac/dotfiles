#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
                        ██████╗  ██████╗ ████████╗███████╗
                        ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
                        ██║  ██║██║   ██║   ██║   ███████╗
                        ██║  ██║██║   ██║   ██║   ╚════██║
                        ██████╔╝╚██████╔╝   ██║   ███████║
                        ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
"""
print(__doc__)

import argparse
import platform
import subprocess
import os

from installer.colors import RED, GREEN, YELLOW, CYAN, BLUE
from installer.setup_logs import setup_logging, log
from installer.files import copy_files_or_directories
from installer.ui import message_box
from installer.actions import (
    execute_post_install_actions,
    action_zgen_update,
    action_vim_update,
    action_install_neovim_py,
    action_shell_to_zsh,
    action_gitconfig_secret,
)
from installer.setup_config import load_config

def check_and_unset_alias():
    message_box("Checking if vim is aliased to nvim", color=CYAN)

    try:
        # Check if 'nvim' is aliased to 'vim'
        alias_check = subprocess.check_output("/bin/zsh -i -c 'alias' | grep 'alias nvim'", shell=True).decode('utf-8')
        if 'vim' in alias_check:
            print("vim is aliased to nvim. Unsetting the alias now.")
            os.system("/bin/zsh -i -c 'unalias nvim'")
    except subprocess.CalledProcessError:
        # If 'nvim' is not aliased, do nothing
        pass

def main():
    setup_logging()
    check_and_unset_alias()

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f", "--force", action="store_true", default=False, help="If set, it will override existing files"
    )
    parser.add_argument("--config", default="config.yaml", help="Path to the YAML config file")
    parser.add_argument("--skip-vimplug", action="store_true", help="If set, do not update vim plugins.")
    parser.add_argument("--skip-zgen", action="store_true", help="If set, skip zgen updates.")
    parser.add_argument("--skip-shell-to-zsh", action="store_true", help="If set, skip changing shell to zsh.")
    args = parser.parse_args()

    config = load_config(args.config)
    tasks = config.get("tasks", {})
    current_os = platform.system().lower()

    # get current directory (absolute path)
    current_dir = os.path.abspath(os.path.dirname(__file__))
    os.chdir(current_dir)

    message_box("Copying dirs & files outlined in config.yaml", color=CYAN)
    for task in tasks:
        os_condition = task.get("os")
        if os_condition and os_condition != current_os:
            continue

        target = os.path.expanduser(task.get("target", ""))
        source = os.path.join(current_dir, os.path.expanduser(task.get("source", "")))

        copy_files_or_directories(target, source, args)

    errors = []  # Initialize an empty list to collect errors

    message_box("Post Install Actions", color=YELLOW, use_bold=True)
    # Post install actions
    post_install_actions = [
        action_install_neovim_py,
        action_shell_to_zsh,
        lambda _, errors: action_gitconfig_secret(errors),  # Pass errors to action_gitconfig_secret
        lambda args, errors: action_zgen_update(args, errors),
        ["bash", "install-tmux.sh"],
    ]

    # Setup Vim & Neovim
    vim_executables = ["nvim", "vim"]  # Iterate through the list and execute action_vim_update for each executable

    for executable in vim_executables:
        action_vim_update(executable, args, errors)

    execute_post_install_actions(post_install_actions, args, errors)

    if errors:
        print("Inside the errors block")
        message_box("You have %3d warnings or errors -- check the logs!" % len(errors), color=YELLOW, use_bold=True)
        for action_title, error_message in errors:
            log(f"   [{action_title}] {error_message}", color=RED)
        log("\n")
    else:
        message_box("✔  You are all set! ", color=GREEN, use_bold=True)

    log("- Please restart the shell (e.g. " + CYAN("`exec zsh`") + ") if necessary.")
    log("\n\n", cr=False)


if __name__ == "__main__":
    main()
