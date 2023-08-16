import subprocess
import os
import shutil
import sys


from .setup_logs import log
from .colors import RED, CYAN, WHITE, GREEN
from .ui import message_box

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
        log(str(e), color=RED, action_title="action_zgen_update", errors=errors)

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
        log(str(e), color=RED, action_title="action_gitconfig_secret", errors=errors)
