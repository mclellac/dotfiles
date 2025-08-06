# Mutt Configuration

This is a modern configuration for the Mutt email client, with a focus on a clean and efficient workflow. It uses a modular structure, with separate files for accounts, colors, and keybindings.

## Installation

To use this configuration, you need to have Mutt or NeoMutt installed. You can then clone this repository and symlink the `mutt` directory to `~/.mutt`.

```bash
git clone <repository-url>
ln -s <repository-path>/mutt ~/.mutt
```

## Configuration

The configuration is split into several files:

- `muttrc`: The main configuration file.
- `acct/`: Contains the configuration for your email accounts. You should have one file per account.
- `colors`: The color scheme.
- `keybindings`: Custom keybindings.
- `mailcap`: Defines how to handle different MIME types.
- `neomutt-sidebar`: Configuration for the NeoMutt sidebar.

### Accounts

To configure your email accounts, you need to create a file in the `acct/` directory for each account. You can use the `acct/personal` and `acct/work` files as templates. You should enter your app passwords for each account in the corresponding file.

### Colors

The color scheme is defined in the `colors` file. This configuration uses a modified version of the popular **Gruvbox** theme, which is designed to be easy on the eyes. You can, of course, customize it to your liking by editing the `colors` file.

### Keybindings

The keybindings are defined in the `keybindings` file. They are heavily inspired by Vim.

#### Global Keys

| Key             | Description                      |
| --------------- | -------------------------------- |
| `q`             | Quit Mutt                        |
| `Q`             | Quit Mutt without confirmation   |
| `,` + `<Space>` | Reload the configuration         |
| `/`             | Search                           |
| `:`             | Enter a command                  |
| `<F2>`          | Switch to the personal account   |
| `<F3>`          | Switch to the work account       |
| `Ctrl-b`        | Toggle the sidebar               |

#### Index View (Mailbox)

| Key             | Description                      |
| --------------- | -------------------------------- |
| `j` / `k`       | Move down / up                   |
| `l` / `<Enter>` | Open the selected email          |
| `h` / `<Left>`  | Go back to the folder list       |
| `gg` / `G`      | Go to the first / last email     |
| `c`             | Change to a different mailbox    |
| `s`             | Sync the mailbox                 |
| `m`             | Compose a new email              |
| `r`             | Reply to all (group reply)       |
| `R`             | Reply to all on the list         |
| `f`             | Forward the email                |
| `dd`            | Delete the selected email        |
| `dt`            | Delete the entire thread         |
| `u`             | Undelete message                 |
| `w`             | Mark email as read               |
| `W`             | Mark email as unread             |
| `*`             | Star a message                   |
| `+`             | Mark as important                |
| `za`            | Collapse all threads             |
| `zA`            | Collapse/expand the current thread |
| `t`             | Tag an entry                     |
| `T`             | Tag a thread                     |

#### Pager View (Reading an Email)

| Key             | Description                      |
| --------------- | -------------------------------- |
| `j` / `k`       | Scroll down / up                 |
| `h` / `<Left>`  | Go back to the index view        |
| `gg` / `G`      | Go to the top / bottom of the email |
| `m`             | Compose a new email              |
| `r`             | Reply to all (group reply)       |
| `R`             | Reply to all on the list         |
| `f`             | Forward the email                |
| `dd`            | Delete the email                 |
| `dt`            | Delete the entire thread         |
| `s`             | Save the email                   |
| `v`             | View attachments                 |
| `|`             | Pipe the email to a command      |
| `za` / `zA`     | Toggle quoted text               |

## Viewing HTML Emails and Attachments

This configuration is set up to handle HTML emails and various attachments in a modern way.

### HTML Emails

HTML emails are automatically rendered to text using `lynx`. This provides a good reading experience directly in the terminal.

If you want to open the original HTML email in your graphical browser, you can add the following macro to your `keybindings` file:

```muttrc
macro index,pager <F9> "<pipe-message>cat > /tmp/mutt-mail.html && xdg-open /tmp/mutt-mail.html<Enter>" "Open email in browser"
```

### Images

If your terminal supports `sixel` graphics, images attached to emails will be displayed directly in the terminal. If not, they will be opened in your default image viewer.

### Other Attachments

Other attachments, like PDFs or office documents, will be opened in their default application using `xdg-open`.

## Tips and Tricks

- You can reload the configuration at any time by pressing `,` followed by `<Space>`.
- The sidebar can be toggled with `Ctrl-b`.
- You can search for emails by pressing `/`.

---

*This README was last updated on 2025-08-06.*
