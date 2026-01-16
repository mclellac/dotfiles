# isync (mbsync) Configuration

`isync` (specifically the `mbsync` executable) is used to synchronize remote IMAP mailboxes to a local Maildir directory. This setup allows Neomutt to read emails locally, providing a faster and more robust experience than direct IMAP connection.

## Configuration File: `mbsyncrc`

The configuration file is located at `~/.config/isync/mbsyncrc`.

An example configuration is provided in `mbsyncrc.example`. You should copy this to `mbsyncrc` and edit it to match your account details.

### Understanding `ACCOUNT_ALIAS`

In this codebase and documentation, `ACCOUNT_ALIAS` is used as a **placeholder** variable. You must replace it with a short, unique name for your email account (e.g., `personal`, `work`, `gmail`).

This alias serves as a key identifier across several configuration files:

1.  **Local Folder Structure**:
    *   Mails will be stored in `~/.local/share/mail/ACCOUNT_ALIAS/`.
    *   Example: `~/.local/share/mail/personal/`

2.  **Mutt Account Config**:
    *   In `~/.config/mutt/acct/ACCOUNT_ALIAS`, you configure settings specific to that account.
    *   Example: `~/.config/mutt/acct/personal`

3.  **isync Channel Name**:
    *   In `mbsyncrc`, the `Channel`, `IMAPAccount`, and `IMAPStore` sections should use this alias.
    *   Example: `Channel personal`

### Setup Instructions

1.  **Create the config**:
    ```bash
    mkdir -p ~/.config/isync
    cp ~/.config/mutt/isync/mbsyncrc.example ~/.config/isync/mbsyncrc
    ```
    *(Note: The install script does this for you)*

2.  **Edit `~/.config/isync/mbsyncrc`**:
    *   Replace `personal` (the example `ACCOUNT_ALIAS`) with your desired account name.
    *   Update `Host`, `User`, and `PassCmd` (or `Pass`).
    *   Ensure `TLSType` is set to `IMAPS` (Gmail requires this).

3.  **Syncing**:
    Run the following command to sync your mail:
    ```bash
    mbsync -a
    ```
    Or sync a specific channel:
    ```bash
    mbsync personal
    ```

4.  **Integration with Notmuch**:
    After syncing, run `notmuch new` to index the new files so they can be searched within Neomutt.

### Troubleshooting

*   **`SSLType is deprecated`**: Update your config to use `TLSType` instead.
*   **`Maildir error: cannot open store ...`**: Ensure the directory `~/.local/share/mail/ACCOUNT_ALIAS` exists. `mbsync` usually creates the structure, but the parent directory must exist. Also check that your `Path` in `mbsyncrc` is correct.
