# Neomutt Configuration (Dracula Theme)

This is a modern configuration for the Neomutt email client, optimized for a clean, efficient workflow with Gmail. It features a modified Dracula theme, vim-like keybindings, and HTML email rendering.

## Dependencies

The `install.sh` script will attempt to install the following dependencies:

- **neomutt**: The email client.
- **urlscan**: For extracting and opening URLs (`Ctrl-l`).
- **w3m**: Required by `beautiful_html_render` for rendering HTML emails inline.
- **pandoc**: Used for converting Markdown to HTML in the composer (`M` macro).
- **git-split-diffs**: Used for viewing patch files (`attach P` macro).
- **xdg-utils (xdg-open)**: For opening links and attachments in default external applications.
- **sc-im**: For viewing spreadsheet attachments (Excel/CSV).
- **mpv**: For viewing video attachments.
- **Perl** & **Sed**: Used in display filters.

*Note: `isync` (mbsync) and `notmuch` are no longer required as this configuration uses IMAP directly.*

## Installation

1.  **Run the install script**:
    ```bash
    ./install.sh
    ```
    This script works on Arch Linux, Debian/Ubuntu, Fedora, and macOS. It will install the dependencies and copy the configuration files to `~/.config/mutt`.

2.  **Configure Accounts**:
    Edit the account files in `~/.config/mutt/acct/`:
    *   `personal`: Update `imap_user`, `imap_pass`, `smtp_url` (with user), `smtp_pass`, `from`, and `realname`.
    *   `work`: Similar configuration if needed.

## Keybindings

Keybindings are defined in `keys/binds.muttrc` and are Vim-inspired.

### Global / Navigation
| Key             | Description                                |
| --------------- | ------------------------------------------ |
| `q`             | Exit / Quit                                |
| `Ctrl-b`        | Toggle Sidebar visibility                  |
| `Ctrl-j`        | Sidebar Next                               |
| `Ctrl-k`        | Sidebar Previous                           |
| `Ctrl-o`        | **Open** highlighted sidebar mailbox       |
| `Ctrl-n`        | Next Unread                                |
| `Ctrl-p`        | Previous Unread                            |
| `<F2>`          | **Switch to Personal Account**             |
| `<F3>`          | **Switch to Work Account**                 |
| `c`             | Compose Mail                               |

### Index View (Mail List)
| Key             | Description                                |
| --------------- | ------------------------------------------ |
| `j` / `k`       | Next / Previous email                      |
| `gg` / `G`      | First / Last email                         |
| `D`             | **Quick Delete** (Move to Archive & Sync)  |
| `A`             | **Quick Archive** (Move to Archive & Sync) |
| `d`             | Delete Message (Mark for deletion)         |
| `u`             | Undelete Message                           |
| `<space>`       | Flag Message                               |
| `Ctrl-a`        | Mark all as Read                           |
| `Ctrl-l`        | Extract URLs (`urlscan`)                   |
| `\`             | Limit view (filter)                        |
| `x`             | Undo Limit (Show all)                      |
| `#`             | Mark as Complete (Label)                   |
| `r` / `R`       | Reply / Group Reply                        |
| `F`             | Forward                                    |
| `|`             | Pipe message                               |

### Pager View (Reading)
| Key             | Description                                |
| --------------- | ------------------------------------------ |
| `j` / `k`       | Next / Previous line                       |
| `gg` / `G`      | Top / Bottom of message                    |
| `J` / `K`       | Next / Previous entry (skip headers)       |
| `Ctrl-u` / `d`  | Half page Up / Down                        |
| `v`             | View Attachments                           |
| `H`             | View Raw Message                           |
| `Ctrl-l`        | Extract URLs (`urlscan`)                   |

### Compose
| Key             | Description                                |
| --------------- | ------------------------------------------ |
| `y`             | Send Message                               |
| `a`             | Attach File                                |
| `p`             | Postpone (Draft)                           |
| `e`             | Edit Body                                  |
| `t` / `c` / `b` | Edit To / CC / BCC                         |
| `s`             | Edit Subject                               |
| `M`             | Convert Markdown to HTML (Pandoc)          |

## Features

- **HTML Rendering**: HTML emails are rendered inline using `w3m` via the `beautiful_html_render` script.
- **URL Scanning**: Use `Ctrl-l` to list and select URLs from the current message.
- **Gmail Optimization**: "Quick Delete" (`D`) and "Quick Archive" (`A`) are configured to move messages to the Archive folder, mimicking Gmail's archive behavior.
- **Patch Viewing**: Integration with `git-split-diffs` for viewing patches.
