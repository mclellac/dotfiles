# Neomutt Configuration (Dracula Theme)

This is a modern configuration for the Neomutt email client, optimized for Gmail and focused on a clean, efficient workflow. It uses a modular structure with separate files for accounts, colors, keybindings, and sidebar settings.

## Dependencies

To use this configuration effectively, you need the following installed:

- **neomutt**: The email client itself.
- **lynx**: Required for rendering HTML emails inline.
- **xdg-open**: Required for opening links, images, and HTML emails in your default browser/viewer.
- **mktemp**: Used for securely creating temporary files when opening emails in the browser.
 - **libsixel-bin** (optional): Provides `img2sixel` for viewing images inline in the terminal.

## Mouse Support

Mouse support in Neomutt is currently experimental and may require a custom build or a specific version (e.g., compiled with `--devel-mouse`).

To attempt to enable mouse support (for clicking to select emails/folders), uncomment the following line in `~/.mutt/muttrc`:

```bash
set mouse = yes
```

If your version supports it, you will be able to click to select items. If not, this setting may cause an error on startup.

## Configuration Structure

The configuration is split into several files in the `~/.mutt` directory:

- `muttrc`: The main entry point.
- `acct/`: Account-specific configurations (one per file).
- `colors`: The **Dracula** color theme.
- `keybindings`: Custom keybindings (Vim-inspired).
- `mailcap`: MIME type handling (HTML, images, etc.).
- `neomutt-sidebar`: Sidebar configuration.

### Colors

The color scheme uses the **Dracula** theme, offering high contrast and a modern aesthetic that is easy on the eyes.

## Keybindings

The keybindings are heavily inspired by Vim and optimized for speed.

### Global / Navigation

| Key             | Description                      |
| --------------- | -------------------------------- |
| `q`             | Exit context (or quit)           |
| `Q`             | Quit Neomutt                     |
| `/`             | Search                           |
| `\CB`           | Toggle the sidebar               |
| `Ctrl-n` / `Ctrl-p` | Next / Previous mailbox in sidebar |
| `Ctrl-j` / `Ctrl-k` | Next / Previous mailbox in sidebar |
| `Ctrl-o`        | **Open** selected sidebar mailbox |
| `<F2>`          | Switch to Personal account       |
| `<F3>`          | Switch to Work account           |

*Note: Selecting a mailbox in the sidebar only highlights it. You must press `Ctrl-o` to actually open the selected mailbox.*

### Index View (Mail List)

| Key             | Description                      |
| --------------- | -------------------------------- |
| `j` / `k`       | Move down / up                   |
| `gg` / `G`      | Go to first / last email         |
| `e`             | **Archive** (Move to All Mail)   |
| `d` (double)    | Delete email (Trash)             |
| `!`             | Mark as **Unread**               |
| `+`             | Mark as **Important**            |
| `*`             | Star message                     |
| `w`             | Set Flag                         |
| `W`             | Clear Flag                       |
| `r`             | Group reply                      |
| `R`             | List reply                       |
| `za`            | Collapse all threads             |
| `zA`            | Toggle thread collapse           |

### Pager View (Reading)

| Key             | Description                      |
| --------------- | -------------------------------- |
| `B`             | **Open in Browser** (View HTML)  |
| `j` / `k`       | Scroll down / up                 |
| `Ctrl-d` / `Ctrl-u` | Scroll half-page down / up   |
| `v`             | View attachments                 |
| `e`             | Archive                          |
| `d` (double)    | Delete                           |
| `r` / `R`       | Reply (Group / List)             |
| `f`             | Forward                          |

## Viewing HTML Emails and Attachments

### HTML Emails
HTML emails are automatically rendered to text using `lynx` for distraction-free reading in the terminal.

To view complex formatting or images that don't render well in text:
- Press **`B`** while reading an email to open it in your default web browser.

### Images & Attachments
- **Images**:
  - If **libsixel** is installed and your terminal supports it, images will render directly in the terminal window.
  - Otherwise, they will open in your default external image viewer using `xdg-open`.
- **Documents**: PDFs and other documents open in their default system applications via `xdg-open`.

## Gmail Features

This configuration is tuned for Gmail:
- **Archive**: The `e` key moves messages to `[Gmail]/All Mail`.
- **Folders**: Trash, Drafts, and Sent Mail are correctly mapped.
- **Header Caching**: Enabled to speed up loading large mailboxes.
