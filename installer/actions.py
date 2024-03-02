import subprocess
import os
import shutil
import sys

from .setup_logs import log
from rich.console import Console
from rich.panel import Panel

console = Console()


def run_command(command: list[str], check: bool = True, timeout: int = 60) -> subprocess.CompletedProcess:
    """
    Run a command and return the completed process.

    Args:
        command (list[str]): The command to be executed as a list of strings.
        check (bool, optional): If True, raise a CalledProcessError if the command returns a non-zero exit status. Defaults to True.
        timeout (int, optional): The maximum time in seconds to wait for the command to complete. Defaults to 60.

    Returns:
        subprocess.CompletedProcess: The completed process object.

    Raises:
        subprocess.TimeoutExpired: If the command execution exceeds the specified timeout.
        subprocess.CalledProcessError: If the command returns a non-zero exit status.
    """
    try:
        return subprocess.run(command, capture_output=True, text=True, check=check, timeout=timeout)
    except subprocess.TimeoutExpired as e:
        log(f"Command '{' '.join(command)}' timed out after {timeout} seconds", console=console)
        return e
    except subprocess.CalledProcessError as e:
        log(f"Command '{' '.join(command)}' failed with error: {str(e)}", console=console)
        return e


def execute_action(action, errors) -> None:
    """
    Executes the given action by running it as a shell command using zsh.

    Args:
        action (list): A list of strings representing the command to be executed.
        errors (list): A list to store any errors that occur during execution.

    Raises:
        Exception: If an error occurs while executing the command.

    Returns:
        None
    """
    try:
        result = run_command(["zsh", "-c", " ".join(action)])
        if isinstance(result, Exception):
            errors.append((action.__name__, str(result)))
    except Exception as e:
        errors.append((action.__name__, str(e)))
        log(str(e), console=console)


def execute_post_install_actions(actions, errors, console) -> None:
    """
    Executes a list of post-install actions.

    Args:
        actions (list): A list of tuples representing the actions to be executed. Each tuple contains a function and its arguments.
        errors (list): A list to store any errors that occur during execution.
        console: The console object used for logging.

    Returns:
        None
    """
    for action in actions:
        func, args = action
        try:
            func(*args, errors=errors, console=console)
        except Exception as e:
            log("An error occurred while executing a post install action:", console=console)
            log(str(e), console=console)
            errors.append((str(func), str(e)))


def action_zgen_update(args, errors, console):
    """
    Update zgen plugins.

    Args:
        args (list): List of command-line arguments.
        console (Console): Console object for printing messages.

    Raises:
        RuntimeError: If the command times out or fails with an error.
    """
    console.print(Panel("Action: zgen update", style="cyan", width=80))

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

    result = run_command(["zsh", "-c", zsh_command])
    if isinstance(result, Exception):
        raise RuntimeError(str(result))


def action_vim_update(vim_executable, args, errors, console):
    """
    Update VIM or Neovim.

    Args:
        vim_executable (str): The path to the VIM or Neovim executable.
        args (Namespace): Command-line arguments.
        errors (list): A list to store any errors encountered during the update process.
        console (Console): The console object used for printing messages.

    Raises:
        Exception: If an error occurs during the update process.
    """
    try:
        is_neovim = vim_executable.lower() == "nvim"

        if is_neovim:
            console.print(Panel("Action: VIM/Neovim update", style="cyan", width=80))
            vim_command = (
                f'{vim_executable} --headless "+Lazy! sync" +qa && echo "Sync complete." || echo "Neovim sync failed."'
            )
            console.print(vim_command)
        else:
            vim_command = f"nohup {vim_executable} +PlugUpdate +qall > /dev/null 2>&1 &"
            console.print(vim_command)

        if not args.skip_vimplug:
            result = run_command(vim_command.split())
            if isinstance(result, Exception):
                errors.append(("action_vim_update", str(result)))
        else:
            log(f"{vim_command} (Skipped)", style="cyan", console=console)
    except Exception as e:
        errors.append(("action_vim_update", str(e)))
        log(str(e), console=console)


def action_install_neovim_py(args, errors, console) -> None:
    """
    Run the install-neovim-py.sh script.

    Args:
        args: The arguments passed to the function.
        errors: The list to store any errors encountered during execution.
        console: The console object used for printing messages.

    Returns:
        None
    """
    console.print(Panel("Action: Run install-neovim-py.sh", style="cyan", width=80))

    result = run_command(["zsh", "install-neovim-py.sh"])
    if isinstance(result, Exception):
        errors.append(("action_install_neovim_py", str(result)))
    else:
        log(result.stdout, style="green", console=console)


def action_shell_to_zsh(args, errors, console) -> None:
    """
    Change the default shell to zsh.

    Args:
        args: Command line arguments.
        errors: List to store any errors encountered.
        console: Console object for printing messages.

    Returns:
        None
    """
    console.print(Panel("Action: Change shell to zsh", style="cyan", width=80))

    if not shutil.which("/bin/zsh"):
        errors.append(("action_shell_to_zsh", "/bin/zsh not found. Please install zsh."))
        sys.exit(1)

    current_shell = os.path.basename(os.environ["SHELL"])
    if current_shell.lower() != "zsh":
        log("Please type your password if you wish to change the default shell to ZSH", style="yellow", console=console)
        result = run_command(["chsh", "-s", "/bin/zsh"])
        if isinstance(result, Exception):
            errors.append(("action_shell_to_zsh", str(result)))
    else:
        log("User's shell is already zsh.", style="white", console=console)


def action_gitconfig_secret(args, errors, console) -> None:
    """
    Configure git user name and email by creating or updating the ~/.gitconfig.secret file.

    Args:
        args (list): Command-line arguments passed to the function.
        errors (list): List to store any errors encountered during execution.
        console (Console): Console object for printing messages.

    Returns:
        None
    """
    console.print(Panel("Action: gitconfig.secret", style="cyan", width=80))

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
                result_name = run_command(["git", "config", "--file", gitconfig_secret_path, "user.name", git_username])
                result_email = run_command(["git", "config", "--file", gitconfig_secret_path, "user.email", git_useremail])
                if isinstance(result_name, Exception) or isinstance(result_email, Exception):
                    errors.append(("action_gitconfig_secret", "Failed to configure git user name or email."))
            else:
                log("Missing name or email, exiting.", style="red", console=console)
                sys.exit(1)
        else:
            log("Git user name and email are already set with the values:", style="green", console=console)
            log("user.name  : " + user_name, style="green3", console=console)
            log("user.email : " + user_email, style="green3", console=console)

    except Exception as e:
        errors.append(("action_gitconfig_secret", str(e)))
        log(str(e), style="red", action_title="action_gitconfig_secret", console=console)
