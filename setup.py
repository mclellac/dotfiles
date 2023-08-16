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

import sys
import shutil
import argparse
import os
import platform
import subprocess
import logging
import yaml

from os import makedirs


# Color formatting functions
def color_wrap(ansicode):
    return lambda msg: ansicode + str(msg) + "\033[0m"


# Color formatting functions
GRAY = color_wrap("\033[0;37m")
WHITE = color_wrap("\033[1;37m")
RED = color_wrap("\033[0;31m")
GREEN = color_wrap("\033[0;32m")
YELLOW = color_wrap("\033[0;33m")
CYAN = color_wrap("\033[0;36m")
BLUE = color_wrap("\033[0;34m")


def setup_logging():
    logging.basicConfig(format="%(message)s", stream=sys.stdout, level=logging.INFO)


def log(msg, color=None, cr=True, action_title=None, errors=None):
    """
    Log a message with optional color, action title, error handling, and newline control.

    Args:
        msg (str): The message to log.
        color (callable, optional): A color formatting function to apply to the message.
                                    For example: color_wrap("\033[0;31m") to make the message red.
        cr (bool, optional): Whether to add a newline after logging the message. Default is True.
        action_title (str, optional): Title of the action associated with the message.
        errors (list, optional): A list to append errors or messages along with their action titles.

    Examples:
        log("Regular log message")
        log("Colored log message", color=RED)
        log("Error message", color=RED, action_title="My Action")
        log("Error message with continue", color=RED, action_title="My Action", errors=[])

    """
    if color:
        msg = color(msg)

    if action_title:
        msg = f"{action_title}: {msg}"

    logging.info(msg)

    if errors is not None and action_title is not None:
        errors.append((action_title, msg))

    if cr:
        logging.info("")


def message_box(msg, color=WHITE, use_bold=False):
    # Adjust the width to 80 characters
    box_width = 80

    # Split the message into multiple lines if it's too long
    lines = []
    words = msg.split()
    current_line = ""
    for word in words:
        if len(current_line) + len(word) + 1 <= 50:  # Maximum line length is 50 characters
            current_line += " " + word
        else:
            lines.append(current_line)
            current_line = word
    if current_line:
        lines.append(current_line)

    # Calculate padding for centering the message
    pad_width = (box_width - max(len(line) for line in lines)) // 2

    # Construct the message box
    box_lines = [
        "┏" + ("━" * box_width) + "┓",
        *["┃" + " " * pad_width + line.ljust(box_width - pad_width * 2) + " " * pad_width + "┃" for line in lines],
        "┗" + ("━" * box_width) + "┛",
    ]

    # Join the box lines and log the message
    box_msg = "\n".join(box_lines)
    if use_bold:
        log(box_msg, color=color, cr=False)
    else:
        log(box_msg, color=color, cr=False)


def create_symbolic_link(target, source, args):
    # bad entry if source does not exist...
    if not os.path.lexists(source):
        log(RED("source %s : does not exist" % source))
        return

    # if --force option is given, delete and override the previous symlink
    if os.path.lexists(target):
        is_broken_link = os.path.islink(target) and not os.path.exists(os.readlink(target))

        if args.force or is_broken_link:
            if os.path.islink(target):
                os.unlink(target)
            else:
                log(
                    "{:60s} : {}".format(
                        BLUE(target), YELLOW("already exists but not a symlink; --force option ignored")
                    ),
                    cr=False,
                )
        else:
            log(
                "{:60s} : {}".format(
                    BLUE(target),
                    GRAY("already exists, skipped")
                    if os.path.islink(target)
                    else YELLOW("exists, but not a symbolic link. Check by yourself!!"),
                ),
                cr=False,
            )

    # make a symbolic link if available
    if not os.path.lexists(target):
        mkdir_target = os.path.split(target)[0]
        makedirs(mkdir_target, exist_ok=True)
        log(GREEN("Created directory : %s" % mkdir_target))
        os.symlink(source, target)
        log("{:20s} {} {}".format(BLUE(target), CYAN("━━"), GREEN("'%s'" % source)), cr=False)


def execute_action(action, errors):
    try:
        subprocess.run(action, shell=True)
    except Exception as e:
        log(str(e), "execute_action", errors)


def execute_post_install_actions(actions, args, errors):
    for action in actions:
        try:
            if callable(action):
                if action.__name__ == "action_gitconfig_secret":
                    action()  # Call the function without any arguments
                else:
                    action(args, errors)  # Pass both args and errors to the function
            elif isinstance(action, list):
                execute_action(action, errors)  # Execute the bash command
        except Exception as e:
            log("An error occurred while executing a post install action:", color=RED)
            log(str(e))
            errors.append(action)


def load_config(filename):
    try:
        with open(filename, "r") as file:
            config = yaml.safe_load(file)
            message_box("YAML config opened.", color=YELLOW)
        return config
    except Exception as e:
        log(f"Error loading config file: {e}")
        sys.exit(1)


def action_zgen_update(args, errors):
    message_box("Action: zgen update", color=CYAN)

    # Source zplug and list plugins
    zsh_command = """
    DOTFILES_UPDATE=1 __p9k_instant_prompt_disabled=1 source {home}/.zshrc
    if ! which zgen > /dev/null; then
        echo -e '\\033[0;31mERROR: zgen not found. Double check the submodule exists, and you have a valid ~/.zshrc!\\033[0m'
        ls -alh ~/.zsh/zgen/
        ls -alh ~/.zshrc
        exit 1;
    fi
    zgen reset
    zgen update
    """.format(
        home=os.path.expanduser("~")
    )

    try:
        subprocess.run(["zsh", "-c", zsh_command], shell=True)
    except Exception as e:
        print("An error occurred:", e)


def action_vim_update(vim_executable, args, errors):
    try:
        is_neovim = False
        result = subprocess.run([vim_executable, "--version"], capture_output=True, text=True)
        version_output = result.stdout.lower()
        if "neovim" in version_output:
            is_neovim = True

        if is_neovim:
            message_box("Action: Neovim update", color=CYAN)
            log('nvim --headless "+Lazy! sync" +qa && echo "nvim sync\'d" || echo "nvim sync failed"', color=WHITE)
            vim_command = (
                f'{vim_executable} --headless "+Lazy! sync" +qa && echo "Sync complete." || echo "Neovim sync failed."'
            )
        else:
            message_box("Action: Vim update", color=CYAN)
            log("vim +PlugUpdate +qall", color=WHITE)
            vim_command = f"{vim_executable} +PlugUpdate +qall"

        if not args.skip_vimplug:
            subprocess.run(vim_command, shell=True)
        else:
            log(f"{vim_command} (Skipped)", color=CYAN)
    except Exception as e:
        log(str(e), "action_vim_update", errors)


def action_install_neovim_py(args, errors):
    message_box("Action: neovim", color=CYAN)

    try:
        subprocess.run(["bash", "install-neovim-py.sh"])
    except Exception as e:
        log(str(e), "action_install_neovim_py", errors)


def action_shell_to_zsh(args, errors):
    message_box("Action: Change shell to zsh", color=CYAN)

    if not shutil.which("/bin/zsh"):
        log("Error: /bin/zsh not found. Please install zsh.", "action_shell_to_zsh", errors)
        sys.exit(1)

    current_shell = os.path.basename(os.environ["SHELL"])
    if current_shell.lower() != "zsh":
        log("Please type your password if you wish to change the default shell to ZSH", color=YELLOW)
        subprocess.run(["chsh", "-s", "/bin/zsh"])
    else:
        log("Users shell is already zsh.", color=WHITE)


def action_gitconfig_secret(errors):
    message_box("Action: gitconfig.secret", color=CYAN)

    gitconfig_secret_path = os.path.expanduser("~/.gitconfig.secret")

    try:
        if not os.path.exists(gitconfig_secret_path):
            with open(gitconfig_secret_path, "w") as f:
                f.write("# vim: set ft=gitconfig:\n")

        config_result = subprocess.run(
            ["git", "config", "--file", gitconfig_secret_path, "user.name"], capture_output=True, text=True
        )
        user_name = config_result.stdout.strip() if config_result.returncode == 0 else None

        config_result = subprocess.run(
            ["git", "config", "--file", gitconfig_secret_path, "user.email"], capture_output=True, text=True
        )
        user_email = config_result.stdout.strip() if config_result.returncode == 0 else None

        if not user_name or not user_email:
            log("[!!!] Please configure git user name and email:", color=YELLOW)
            if not user_name:
                git_username = input("(git config user.name) Please input your name  : ")
            else:
                git_username = user_name

            if not user_email:
                git_useremail = input("(git config user.email) Please input your email : ")
            else:
                git_useremail = user_email

            if git_username and git_useremail:
                subprocess.run(["git", "config", "--file", gitconfig_secret_path, "user.name", git_username])
                subprocess.run(["git", "config", "--file", gitconfig_secret_path, "user.email", git_useremail])
            else:
                log("Missing name or email, exiting.", color=RED)
                sys.exit(1)
        else:
            log("Git user name and email are already set with the values:", color=WHITE)
            log("user.name  : " + user_name, color=GREEN, cr=False)
            log("user.email : " + user_email, color=GREEN, cr=True)

    except Exception as e:
        log(str(e), "action_gitconfig_secret", errors)


def main():
    setup_logging()

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f", "--force", action="store_true", default=False, help="If set, it will override existing symbolic links"
    )
    parser.add_argument("--config", default="config.yaml", help="Path to the YAML config file")
    parser.add_argument("--skip-vimplug", action="store_true", help="If set, do not update vim plugins.")
    parser.add_argument("--skip-zgen", action="store_true", help="If set, skip zgen updates.")
    args = parser.parse_args()

    config = load_config(args.config)
    tasks = config.get("tasks", {})
    current_os = platform.system().lower()

    # get current directory (absolute path)
    current_dir = os.path.abspath(os.path.dirname(__file__))
    os.chdir(current_dir)

    message_box("Setting symbolic links from config.yaml", color=CYAN)
    for task in tasks:
        os_condition = task.get("os")
        if os_condition and os_condition != current_os:
            continue

        target = os.path.expanduser(task.get("target", ""))
        source = os.path.join(current_dir, os.path.expanduser(task.get("source", "")))

        create_symbolic_link(target, source, args)

    errors = []  # Initialize an empty list to collect errors

    message_box("Post Install Actions", color=YELLOW, use_bold=True)
    # Post install actions
    post_install_actions = [
        action_install_neovim_py,
        action_shell_to_zsh,
        lambda _, errors: action_gitconfig_secret(errors),  # Pass errors to action_gitconfig_secret
        action_zgen_update,
        ["bash", "install-tmux.sh"],
    ]

    execute_post_install_actions(post_install_actions, args, errors)

    # Setup Vim & Neovim
    vim_executables = ["nvim", "vim"]  # Iterate through the list and execute action_vim_update for each executable

    for executable in vim_executables:
        action_vim_update(executable, args, errors)

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
