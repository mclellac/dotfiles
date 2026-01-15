# Neomutt Configuration (Dracula Theme)

This is a modern configuration for the Neomutt email client, optimized for a clean, efficient workflow with Gmail. It features a modified Dracula theme, vim-like keybindings, and HTML email rendering.

## Dependencies

To use this configuration effectively, you need the following installed:

- **neomutt**: The email client.
- **isync (mbsync)**: For syncing emails (IMAP) to local storage.
- **notmuch**: For indexing and searching emails.
- **urlscan**: For extracting and opening URLs (`Ctrl-l`).
- **w3m**: Required by `beautiful_html_render` for rendering HTML emails inline.
- **pandoc**: Used for converting Markdown to HTML in the composer (`M` macro).
- **git-split-diffs**: Used for viewing patch files (`attach P` macro).
- **xdg-open**: For opening links and attachments in default external applications.
- **sc-im**: For viewing spreadsheet attachments (Excel/CSV).
- **mpv**: For viewing video attachments.
- **Perl** & **Sed**: Used in display filters.

## Installation

1.  **Clone/Copy** this directory to `~/.config/mutt`.
2.  **Scripts**: Ensure the scripts in `scripts/` are executable (`chmod +x scripts/*`).
3.  **Accounts**: Configure your accounts in `acct/` (e.g., `personal`, `work`).
4.  **Paths**: The configuration assumes files are located in `~/.config/mutt`.
    *   *Note*: The `mailcap` file currently references `~/.mutt/scripts/`. You may need to create a symlink (`ln -s ~/.config/mutt ~/.mutt`) or update the paths in `mailcap` to match your location.

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
| `f`             | Change Folder                              |
| `c`             | Compose Mail                               |
| `O`             | Run `mbsync` to sync all mail              |

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
