# mclellac dotfiles

A collection of my personal dotfiles.

## Installation & Requirements

This repository is tailored for my specific use-case, but you are welcome to use it as you like. The provided Python script automates the setup process for various configurations and installations on Unix-like systems. It simplifies the installation of packages, copying directories and files, and performing post-installation actions. Below is an overview of its functionalities and usage instructions.

### Requirements

- Python 3.6 or higher
- Unix-like operating system (Linux, macOS, etc.)

### Mutt Configuration

This repository includes a comprehensive configuration for Neomutt, designed for a fast, local-only email workflow using `isync` (mbsync) and `notmuch`.

#### Dependencies

The `install-mutt.sh` script automates the installation of the following dependencies:
-   `neomutt`: The email client.
-   `isync`: For syncing email (IMAP/SMTP).
-   `notmuch`: For indexing and tagging email.
-   `urlscan`: For handling URLs.
-   `w3m` & `glow`: For rendering HTML emails.
-   `pandoc`: For converting Markdown to HTML in the composer.
-   `khard`: For address book management (requires `vobject`).
-   `msmtp`: For sending email.
-   `fzf`: For fuzzy finding mailboxes.
-   `git-split-diffs`: For viewing patch files.

#### Post-Installation Configuration

After running `./install-mutt.sh`, you need to perform a few manual steps to configure your accounts:

1.  **Configure Accounts**: Update `~/.config/mutt/acct/personal` and `~/.config/mutt/acct/work` with your email details.
2.  **Configure mbsync**: Edit `~/.config/isync/mbsyncrc` with your IMAP/SMTP details.
3.  **Configure MSMTP**: Create or edit `~/.msmtprc` for sending email.
    ```
    # Example ~/.msmtprc
    defaults
    auth           on
    tls            on
    tls_trust_file /etc/ssl/certs/ca-certificates.crt
    logfile        ~/.msmtp.log

    account personal
    host smtp.gmail.com
    port 587
    from user@gmail.com
    user user@gmail.com
    passwordeval "pass email/personal"

    account default : personal
    ```
4.  **Configure Khard**: Ensure you have a `~/.config/khard/khard.conf` pointing to your contacts (usually synced via vdirsyncer).
5.  **Initialize Mail**: Run `mbsync -a` to fetch mail, then `notmuch new` to index it.

### Installation

```bash
git clone https://github.com/mclellac/dotfiles.git ~/.config/
cd ~/.config/dotfiles
pip install -r requirements.txt
./setup.py
```

## Usage

### Command-line Options

| Option                 | Description                                                               |
|------------------------|---------------------------------------------------------------------------|
| `-f, --force`          | Override existing files if necessary.                                     |
| `--config`             | Specify the path to the YAML configuration file. Default is `config.yaml`.|
| `--skip-vimplug`       | Skip updating Vim plugins.                                                |
| `--skip-zgen`          | Skip updating Zgen.                                                       |
| `--skip-shell-to-zsh`  | Skip changing the shell to Zsh.                                           |
| `--skip-packages`      | Skip package installation.                                                |

### Configuration File

The script utilizes a YAML configuration file (`config.yaml` by default) to define tasks. You can customize the tasks according to your requirements. Refer to the provided `config.yaml` for the structure and examples.

## Functionality Overview

### Package Installation

The script detects the operating system and installs packages using appropriate package managers such as `dnf`, `pacman`, `apt`, or `brew`. It also installs Python packages using `pip`.

### File and Directory Copying

It copies directories and files specified in the configuration file to desired locations.

### Post-Installation Actions

After the main installation tasks, the script performs various post-installation actions, such as updating Vim/Neovim, changing the shell to Zsh, and updating Zgen.

### Logging and Error Handling

The script provides rich logging and error handling features to ensure smooth execution and easy debugging.

### Customization

Feel free to modify the script and the configuration file to suit your specific setup requirements. You can add new tasks, change package lists, or extend post-installation actions as needed.

## Hyprland Configuration

This section provides a detailed overview of the Hyprland window manager configuration used in this dotfiles repository. The setup is highly customized with a focus on aesthetics, usability, and a powerful theming system.

### File Structure

The core of the configuration resides in the `~/.config/hypr/` directory. Here's a breakdown of the key files and directories:

-   `hyprland.conf`: The main entry point for Hyprland's configuration. It sources all other configuration files, creating a modular and easy-to-manage setup.
-   `monitors.conf`: Defines monitor setups, resolutions, scaling, and workspaces. It includes commented-out examples for different types of displays (Retina, 4K, 1080p).
-   `input.conf`: Configures input devices like keyboards and touchpads, including layout, repeat rate, and sensitivity.
-   `bindings.conf`: Contains custom keybindings for launching applications, managing windows, and running scripts. This is where you can customize your keyboard shortcuts.
-   `envs.conf`: Sets essential environment variables for the Hyprland session, ensuring applications run correctly under Wayland with proper theming.
-   `autostart.conf`: Specifies applications and scripts to be launched automatically when Hyprland starts.
-   `themes/`: This directory contains all available themes. Each theme is a subdirectory containing a complete set of configuration files for Hyprland and other applications.
-   `theme/`: This directory holds the *currently active* theme. The files here are symlinks to the selected theme in the `themes/` directory. **Do not edit files in this directory directly.**
-   `bin/`: Contains a collection of helper scripts that power much of the functionality of this setup, from theme switching to application launchers and system management menus.
-   `scripts/`: Contains scripts that are used by Hyprland but are not intended to be run directly by the user.
-   `config/`: Holds configuration files for other applications that are styled by the theming system, such as Alacritty, Waybar, and Walker.

### Dependencies

This setup relies on a number of external applications and tools. You will need to install them using your package manager. For Arch Linux, you can use `pacman` for official packages and an AUR helper like `yay` for packages from the Arch User Repository.

**Core Components**
*   `hyprland`: The Wayland compositor itself.
*   `uwsm`: The Universal Wayland Session Manager, used to launch all applications.
*   `waybar`: The status bar at the top of the screen.
*   `walker-git`: The application launcher and menu frontend.
*   `hypridle` & `hyprlock`: For idle management and screen locking.
*   `mako`: The notification daemon.
*   `swaybg`: For setting the desktop background.
*   `swayosd`: The on-screen display for volume, brightness, etc.
*   `polkit-gnome`: The PolicyKit authentication agent.
*   `xdg-utils`: For core desktop integration like identifying the default browser.
*   `wl-clipboard`: For Wayland clipboard utilities (`wl-copy`, `wl-clip-persist`).

**System Utilities**
*   `pamixer`: For programmatic audio control.
*   `playerctl`: To control media players.
*   `power-profiles-daemon`: For managing system power profiles.
*   `jq`: A command-line JSON processor, used in various scripts.
*   `fastfetch`: For displaying system information.
*   `yay`: An AUR helper, required for installing some packages.

**Screenshotting & Recording**
*   `hyprshot`: A screenshot tool for Hyprland.
*   `satty-bin`: A powerful screen annotation and capture tool.
*   `wf-recorder`: For screen recording on Wayland.

**Input & Language**
*   `fcitx5-im`, `fcitx5-qt`, `fcitx5-gtk`: For input method support.

**Fonts**
*   `ttf-meslo-nerd`
*   `ttf-firacode-nerd`
*   `ttf-victor-mono-nerd`
*   The custom `hypr` icon font is included in this repository.

**Core Applications**
*   `alacritty` or `kitty`: A fast, GPU-accelerated terminal emulator.
*   `neovim`: The editor.
*   `btop`: The system resource monitor.
*   `nautilus`: The file manager.
*   `chromium`: The recommended web browser for full feature compatibility (like web app mode).

A consolidated installation command for Arch Linux would look something like this (excluding AUR packages):

```bash
sudo pacman -S --needed hyprland waybar hypridle hyprlock mako swaybg swayosd polkit-gnome xdg-utils wl-clipboard pamixer playerctl power-profiles-daemon jq fastfetch neovim btop nautilus chromium alacritty kitty fcitx5-im fcitx5-qt fcitx5-gtk ttf-meslo-nerd ttf-firacode-nerd ttf-victor-mono-nerd
```

For AUR packages (`uwsm`, `walker-git`, `satty-bin`, `yay`, etc.), you will need to use `yay`:
```bash
yay -S --needed uwsm walker-git satty-bin
```

### Theming

A powerful script-based theming system allows for a consistent look and feel across the entire desktop environment.

-   **How it Works**: The `hypr-theme-set <theme-name>` script creates symbolic links from the chosen theme's files in `hypr/themes/<theme-name>/` to the `hypr/theme/` directory. Hyprland and other applications are configured to load their settings from this `hypr/theme/` directory, instantly applying the new look.
-   **Available Themes**: To see a list of all available themes, run `hypr-theme-list`.
-   **Switching Themes**: Use `hypr-theme-set <theme-name>` to switch to a different theme. You can also use `hypr-theme-next` to cycle through available themes.
-   **Creating a New Theme**: The easiest way to create a new theme is to copy an existing one (`cp -r hypr/themes/rose-pine hypr/themes/my-awesome-theme`), customize the files within the new directory, and then apply it with `hypr-theme-set my-awesome-theme`.

### Keybindings

The following keybindings are defined in `~/.config/hypr/bindings.conf`. This list covers application and web app launchers. For tiling, window management, and media keybindings, please refer to the files in `~/.config/hypr/default/hypr/bindings/`.

| Keybinding | Description | Action |
| --- | --- | --- |
| `SUPER + Return` | Terminal | Opens a new terminal in the CWD of the active one |
| `SUPER + F` | File manager | Opens Nautilus |
| `SUPER + B` | Browser | Launches the default web browser |
| `SUPER + M` | Music | Launches Spotify |
| `SUPER + N` | Neovim | Launches Neovim in a new terminal |
| `SUPER + T` | Activity | Launches btop in a new terminal |
| `SUPER + D` | Docker | Launches lazydocker in a new terminal |
| `SUPER + G` | Signal | Launches Signal Desktop |
| `SUPER + O` | Obsidian | Launches Obsidian |
| `SUPER + /` | Passwords | Launches 1Password |
| `SUPER + A` | ChatGPT | Opens ChatGPT as a web app |
| `SUPER + SHIFT + A` | Grok | Opens Grok as a web app |
| `SUPER + C` | Calendar | Opens HEY Calendar as a web app |
| `SUPER + E` | Email | Opens HEY Email as a web app |
| `SUPER + Y` | YouTube | Opens YouTube as a web app |
| `SUPER + SHIFT + G`| WhatsApp | Opens WhatsApp as a web app |
| `SUPER + ALT + G` | Google Messages | Opens Google Messages as a web app |
| `SUPER + X` | X | Opens X as a web app |
| `SUPER + SHIFT + X`| X Post | Opens X compose page as a web app |

### Scripts

The `hypr/bin/` directory is filled with powerful `hypr-` scripts. The most important one is `hypr-menu`, which is typically bound to `SUPER + SPACE`. It provides a comprehensive, searchable menu system (using `walker`) to access almost all functionality of the desktop.

The main categories in the menu include:

-   **Apps**: Launch applications.
-   **Learn**: Access documentation for Keybindings, Hypr, Hyprland, etc.
-   **Capture**: Take screenshots or screen recordings.
-   **Toggle**: Enable/disable features like the screensaver, night light, or top bar.
-   **Style**: Change the theme, font, or background.
-   **Setup**: Configure system settings like Audio, Wifi, Bluetooth, Monitors, etc.
-   **Install**: Install new packages, themes, fonts, and development environments.
-   **Remove**: Uninstall packages, themes, etc.
-   **Update**: Update the system, configs, and themes.
-   **System**: Lock screen, suspend, restart, or shutdown.

Other notable scripts include:
-   `hypr-launch-browser`: Launches the system's default web browser.
-   `hypr-launch-webapp`: Launches a URL as a standalone web application using your browser's `--app` feature.
-   `hypr-cmd-terminal-cwd`: A clever script that gets the working directory of the currently focused terminal, so that new terminals can be opened in the same path.

### Customization

-   **Keybindings**: To change or add keybindings, edit `~/.config/hypr/bindings.conf`.
-   **Monitors**: Adjust your monitor layout, resolution, and scaling in `~/.config/hypr/monitors.conf`.
-   **Startup Apps**: Add or remove startup applications in `~/.config/hypr/autostart.conf`.
-   **Themes**: Create or modify themes in the `~/.config/hypr/themes/` directory.
-   **Scripts**: You can modify any of the `hypr-` scripts in `~/.config/hypr/bin/` to change their behavior.
