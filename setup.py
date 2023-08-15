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
import unicodedata
import logging
import yaml


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


def log(msg, cr=True):
    logging.info(msg)
    if cr:
        logging.info("")


def log_with_color(msg, color=WHITE, cr=True):
    log(color(msg), cr=cr)


def log_error(message, action_title=None):
    log_with_color(f"Error in {action_title}: {message}", color=RED)


def log_error_and_continue(message, action_title=None, errors=None):
    log_error(message, action_title)
    if errors is not None:
        errors.append((action_title, message))


def log_boxed(msg, color_fn=WHITE, use_bold=False, len_adjust=0):
    pad_msg = " " + msg + "  "
    l = sum(not unicodedata.combining(ch) for ch in pad_msg) + len_adjust
    if use_bold:
        log_with_color(
            "┏" + ("━" * l) + "┓\n" + "┃" + pad_msg + "┃\n" + "┗" + ("━" * l) + "┛\n", color=color_fn, cr=False
        )
    else:
        log_with_color(
            "┌" + ("─" * l) + "┐\n" + "│" + pad_msg + "│\n" + "└" + ("─" * l) + "┘\n", color=color_fn, cr=False
        )


def execute_action(action, errors):
    try:
        subprocess.run(action, shell=True)
    except Exception as e:
        log_error_and_continue(str(e), "execute_action", errors)


def execute_post_action(action, action_title, args, errors):
    try:
        if callable(action):
            action(args)  # Call the function if it's a regular function
        elif isinstance(action, str):
            execute_action(action, errors)  # Execute the bash command
    except Exception as e:
        log_error(str(e), action_title)
        errors.append(action_title)


def load_config(filename):
    try:
        with open(filename, "r") as file:
            config = yaml.safe_load(file)
        return config
    except Exception as e:
        log_error(f"Error loading config file: {e}")
        sys.exit(1)


def action_zgen_update(args, errors):
    log_boxed("Action: zgen update", color_fn=CYAN)

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
            log_boxed("Action: neovim update", color_fn=CYAN)
            log_with_color('nvim "+Lazy! sync" +qa', color=WHITE)
            vim_command = [vim_executable, '"+Lazy\! sync"', "+qa"]
        else:
            log_boxed("Action: Vim update", color_fn=CYAN)
            log_with_color("vim +PlugUpdate +qall", color=CYAN)
            vim_command = [vim_executable, "+PlugUpdate", "+qall"]

        if not args.skip_vimplug:
            subprocess.run(vim_command)
        else:
            log_with_color("{vim_command} (Skipped)".format(vim_command=" ".join(vim_command)), color=CYAN)
    except Exception as e:
        log_error_and_continue(str(e), "action_vim_update", errors)


def action_install_neovim_py(args, errors):
    log_boxed("Action: neovim", color_fn=CYAN)

    try:
        subprocess.run(["bash", "install-neovim-py.sh"])
    except Exception as e:
        log_error_and_continue(str(e), "action_install_neovim_py", errors)


def action_shell_to_zsh(args, errors):
    log_boxed("Action: Change shell to zsh", color_fn=CYAN)

    if not shutil.which("/bin/zsh"):
        log_error("Error: /bin/zsh not found. Please install zsh.", "action_shell_to_zsh", errors)
        sys.exit(1)

    current_shell = os.path.basename(os.environ["SHELL"])
    if current_shell.lower() != "zsh":
        log_with_color("Please type your password if you wish to change the default shell to ZSH", color=YELLOW)
        subprocess.run(["chsh", "-s", "/bin/zsh"])
    else:
        log_with_color("Users shell is already zsh.", color=WHITE)


def action_gitconfig_secret(errors):
    log_boxed("~/gitconfig.secret", color_fn=CYAN)

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
            log_with_color("[!!!] Please configure git user name and email:", color=YELLOW)
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
                log_with_color("Missing name or email, exiting.", color=RED)
                sys.exit(1)
        else:
            log_with_color("Git user name and email are already set with the values:", color=WHITE)
            log_with_color("user.name  : " + user_name, color=GREEN)
            log_with_color("user.email : " + user_email, color=GREEN)

    except Exception as e:
        log_error_and_continue(str(e), "action_gitconfig_secret", errors)


def main():
    setup_logging()

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f", "--force", action="store_true", default=False, help="If set, it will override existing symbolic links"
    )
    parser.add_argument("--config", default="config.yaml", help="Path to the YAML config file")
    parser.add_argument("--skip-vimplug", action="store_true", help="If set, do not update vim plugins.")
    parser.add_argument("--skip-zgen", "--skip-zplug", action="store_true", help="If set, skip zgen updates.")
    args = parser.parse_args()

    config = load_config(args.config)
    tasks = config.get("tasks", {})
    current_os = platform.system().lower()

    # get current directory (absolute path)
    current_dir = os.path.abspath(os.path.dirname(__file__))
    os.chdir(current_dir)

    # check if git submodules are loaded properly
    stat = subprocess.check_output("git submodule status --recursive", shell=True, universal_newlines=True)
    submodule_issues = [(l.split()[1], l[0]) for l in stat.split("\n") if len(l) and l[0] != " "]

    if submodule_issues:
        stat_messages = {"+": "needs update", "-": "not initialized", "U": "conflict!"}
        for submodule_name, submodule_stat in submodule_issues:
            log(
                RED(
                    "git submodule {name} : {status}".format(
                        name=submodule_name, status=stat_messages.get(submodule_stat, "(Unknown)")
                    )
                )
            )
        log(RED(" you may run: $ git submodule update --init --recursive"))

        log("")
        log(YELLOW("Do you want to update submodules? (y/n) "), cr=False)
        shall_we = input().lower() == "y"
        if shall_we:
            git_submodule_update_cmd = "git submodule update --init --recursive"
            # git 2.8+ supports parallel submodule fetching
            try:
                git_version = str(subprocess.check_output("""git --version | awk '{print $3}""", shell=True))
                if git_version >= "2.8":
                    git_submodule_update_cmd += " --jobs 8"
            except Exception as ex:
                pass
            log("Running: %s" % BLUE(git_submodule_update_cmd))
            subprocess.call(git_submodule_update_cmd, shell=True)
        else:
            log(RED("Aborted."))
            sys.exit(1)

    log_boxed("Creating symbolic links", color_fn=CYAN)
    for task in tasks:
        os_condition = task.get("os")
        if os_condition and os_condition != current_os:
            continue

        target = os.path.expanduser(task.get("target", ""))
        source = os.path.join(current_dir, os.path.expanduser(task.get("source", "")))

        # bad entry if source does not exists...
        if not os.path.lexists(source):
            log(RED("source %s : does not exist" % source))
            continue

        # if --force option is given, delete and override the previous symlink
        if os.path.lexists(target):
            is_broken_link = os.path.islink(target) and not os.path.exists(os.readlink(target))

            if args.force or is_broken_link:
                if os.path.islink(target):
                    os.unlink(target)
                else:
                    log(
                        "{:50s} : {}".format(
                            BLUE(target), YELLOW("already exists but not a symbolic link; --force option ignored")
                        )
                    )
            else:
                log(
                    "{:50s} : {}".format(
                        BLUE(target),
                        GRAY("already exists, skipped")
                        if os.path.islink(target)
                        else YELLOW("exists, but not a symbolic link. Check by yourself!!"),
                    )
                )

        # make a symbolic link if available
        if not os.path.lexists(target):
            mkdir_target = os.path.split(target)[0]
            makedirs(mkdir_target, exist_ok=True)
            log(GREEN("Created directory : %s" % mkdir_target))
            os.symlink(source, target)
            log("{:50s} : {}".format(BLUE(target), GREEN("symlink created from '%s'" % source)))

    errors = []  # Initialize an empty list to collect errors

    # Define a list of executable names
    vim_executables = ["nvim", "vim"]

    # Iterate through the list and execute action_vim_update for each executable
    for executable in vim_executables:
        action_vim_update(executable, args, errors)

    log_boxed("                    [ Post Actions ]                    ", color_fn=YELLOW, use_bold=True)
    post_actions = [
        (lambda: action_install_neovim_py(args, errors)),
        (lambda: action_shell_to_zsh(args, errors)),
        (lambda: action_gitconfig_secret(errors)),
        (lambda: action_zgen_update(args, errors)),
        (lambda vim_executable, args, errors: action_vim_update(vim_executable, args, errors))(
            "nvim" if shutil.which("nvim") else "vim", args, errors
        ),
        (["bash", "install-tmux.sh"], errors),  # Using a custom message for this action
    ]

    for action in post_actions:
        try:
            if callable(action):
                action()  # Call the function if it's a regular function
            elif isinstance(action, list):
                execute_action(action, errors)  # Execute the bash command
            # Add this section to iterate through vim_executables
            elif callable(action[0]) and isinstance(action[1], list) and "vim" in action[1]:
                vim_executables = ["nvim", "vim"]
                for executable in vim_executables:
                    action[0](executable, args, errors)
        except Exception as e:
            log_with_color("An error occurred while executing a post install action:", color=RED)
            log(str(e))
            errors.append(action)

    if errors:
        print("Inside the errors block")
        log_boxed("You have %3d warnings or errors -- check the logs!" % len(errors), color_fn=YELLOW, use_bold=True)
        for action_title, error_message in errors:
            log_with_color(f"   [{action_title}] {error_message}", color=RED)
        log("\n")
    else:
        log_boxed("✔  You are all set! ", color_fn=GREEN, use_bold=True)

    log("- Please restart the shell (e.g. " + CYAN("`exec zsh`") + ") if necessary.")
    log("\n\n", cr=False)


if __name__ == "__main__":
    main()
