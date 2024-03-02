import subprocess
import os
import shutil
import sys

from .setup_logs import log
from rich.console import Console
from rich.panel import Panel

console = Console()


def run_command(command: list[str], check: bool = True, timeout: int = 60) -> subprocess.CompletedProcess:
    try:
        return subprocess.run(command, capture_output=True, text=True, check=check, timeout=timeout)
    except subprocess.TimeoutExpired:
        log(f"Command '{' '.join(command)}' timed out after {timeout} seconds", console=console)
    except subprocess.CalledProcessError as e:
        log(f"Command '{' '.join(command)}' failed with error: {str(e)}", console=console)


def execute_action(action, errors):
    try:
        run_command(["zsh", "-c", " ".join(action)])
    except Exception as e:
        log(str(e), console=console)
        errors.append((action.__name__, str(e)))


def execute_post_install_actions(actions, errors, console):
    for action in actions:
        func, args = action
        try:
            func(*args, errors=errors, console=console)
        except Exception as e:
            log("An error occurred while executing a post install action:", console=console)
            log(str(e), console=console)
            errors.append((str(func), str(e)))


def action_zgen_update(args, errors, console):
    console.print(Panel("Action: zgen update", style="cyan"))

    # Source zplug and list plugins
    zsh_command = f"""
    DOTFILES_UPDATE=1 __p9k_instant_prompt_disabled=1 source {os.path.expanduser("~")}/.zshrc
    if ! which zgen > /dev/null; then
        echo -e '\033[0;31mERROR: zgen not found. Double check the submodule exists, and you have a valid ~/.zshrc!\033[0m'
        ls -alh ~/.zsh/zgen/
        ls -alh ~/.zshrc
        exit 1;
    fi
    zgen reset
    zgen update
    """

    try:
        run_command(["zsh", "-c", zsh_command])
    except subprocess.TimeoutExpired as e:
        raise RuntimeError(f"Command '{' '.join(command)}' timed out after {timeout} seconds")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Command '{' '.join(command)}' failed with error: {str(e)}")
    except Exception as e:
        log(args, style="red", action_title="action_zgen_update", errors=errors, console=console)
        log(str(e), style="red", action_title="action_zgen_update", errors=errors, console=console)


def action_vim_update(vim_executable, args, errors, console):
    try:
        is_neovim = vim_executable.lower() == "nvim"

        if is_neovim:
            console.print(Panel("Action: VIM/Neovim update", style="cyan"))
            vim_command = (
                f'{vim_executable} --headless "+Lazy! sync" +qa && echo "Sync complete." || echo "Neovim sync failed."'
            )
            console.print(vim_command)
        else:
            vim_command = f"nohup {vim_executable} +PlugUpdate +qall > /dev/null 2>&1 &"
            console.print(vim_command)

        if not args.skip_vimplug:
            run_command(vim_command.split())
        else:
            log(f"{vim_command} (Skipped)", style="cyan", console=console)
    except Exception as e:
        log(str(e), console=console)
        errors.append(("action_vim_update", str(e)))


def action_install_neovim_py(args, errors, console):
    console.print(Panel("Action: Run install-neovim-py.sh", style="cyan"))

    try:
        run_command(["zsh", "install-neovim-py.sh"])
    except Exception as e:
        log(str(e), "action_install_neovim_py", errors, console)


def action_shell_to_zsh(args, errors, console):
    console.print(Panel("Action: Change shell to zsh", style="cyan"))

    if not shutil.which("/bin/zsh"):
        log("Error: /bin/zsh not found. Please install zsh.", "action_shell_to_zsh", errors, console)
        sys.exit(1)

    current_shell = os.path.basename(os.environ["SHELL"])
    if current_shell.lower() != "zsh":
        log("Please type your password if you wish to change the default shell to ZSH", style="yellow", console=console)
        run_command(["chsh", "-s", "/bin/zsh"])
    else:
        log("Users shell is already zsh.", style="white", console=console)


def action_gitconfig_secret(args, errors, console):
    console.print(Panel("Action: gitconfig.secret", style="cyan"))

    gitconfig_secret_path = os.path.expanduser("~/.gitconfig.secret")

    try:
        if not os.path.exists(gitconfig_secret_path):
            with open(gitconfig_secret_path, "w") as f:
                f.write("# vim: set ft=gitconfig:\n")

        config_result = run_command(["git", "config", "--file", gitconfig_secret_path, "user.name"], check=False)
        user_name = config_result.stdout.strip() if config_result.returncode == 0 else None

        config_result = run_command(["git", "config", "--file", gitconfig_secret_path, "user.email"], check=False)
        user_email = config_result.stdout.strip() if config_result.returncode == 0 else None

        if not user_name or not user_email:
            log("[!!!] Please configure git user name and email:", style="yellow", console=console)
            if not user_name:
                git_username = input("(git config user.name) Please input your name  : ")
            else:
                git_username = user_name

            if not user_email:
                git_useremail = input("(git config user.email) Please input your email : ")
            else:
                git_useremail = user_email

            if git_username and git_useremail:
                run_command(["git", "config", "--file", gitconfig_secret_path, "user.name", git_username])
                run_command(["git", "config", "--file", gitconfig_secret_path, "user.email", git_useremail])
            else:
                log("Missing name or email, exiting.", style="red", console=console)
                sys.exit(1)
        else:
            log("Git user name and email are already set with the values:", style="green", console=console)
            log("user.name  : " + user_name, style="green3", console=console)
            log("user.email : " + user_email, style="green3", console=console)

    except Exception as e:
        log(str(e), style="red", action_title="action_gitconfig_secret", errors=errors, console=console)
