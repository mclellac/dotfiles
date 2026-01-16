# Mutt Configuration Improvements

This document outlines potential improvements for the current neomutt configuration to enhance the user interface, keybindings, and general feature set.

## UI Improvements

1.  **Split View Pager**
    *   **Current:** `pager_index_lines = 0` (Message opens in its own full window).
    *   **Improvement:** Set `pager_index_lines = 10` (or similar) to keep the index visible while reading a message. This provides better context and allows scrolling through the list while previewing, mimicking a "preview pane" workflow.
    *   **Action:** Update `muttrc` with `set pager_index_lines = 10`.

2.  **Dynamic Sidebar**
    *   **Current:** Fixed width of 30 columns.
    *   **Improvement:** Implement a macro to toggle sidebar visibility or width. This allows for focused reading mode or handling of deep folder structures.
    *   **Action:** Add macro: `macro index,pager B '<enter-command>toggle sidebar_visible<enter>'`.

3.  **Relative Line Numbers**
    *   **Current:** Not enabled.
    *   **Improvement:** Enable `set show_numbers = relative` (if supported by the installed neomutt version) to assist with Vim-style vertical navigation (e.g., `10j` to jump down 10 emails).

4.  **Refined Status Bar**
    *   **Current:** Complex format with extensive conditional rendering.
    *   **Improvement:** While visually rich, it could be simplified or augmented with a "Connection/Sync Status" indicator. Since `isync` runs externally, a hook or file-check could update the status bar to show when a sync is in progress.

## Keybinding Improvements

1.  **"Go To" Navigation (`g` prefix)**
    *   **Current:** `gg` (top), `G` (bottom).
    *   **Improvement:** Implement standard Vim-like `g` bindings for quick mailbox navigation.
        *   `gi`: Go to Inbox (`!`)
        *   `gs`: Go to Sent
        *   `gd`: Go to Drafts
        *   `ga`: Go to Archive
        *   `gS`: Go to Spam
    *   **Action:** Define macros in `keys/binds.muttrc`.

2.  **Global Thread Manipulation**
    *   **Current:** `<Left>/<Right>` collapse/expand individual threads.
    *   **Improvement:** Add a binding to collapse or expand *all* threads instantly, which is useful for cleaning up a busy mailing list view.
    *   **Action:** Bind `<Esc>v` (or similar) to `collapse-all`.

3.  **Notmuch Virtual Folder Shortcuts**
    *   **Current:** Relies on `mbsync` (`O`) and manual searches.
    *   **Improvement:** Add direct bindings for common Notmuch queries (Smart Views).
        *   `\t` (Tab): Switch to "Today" (mails from today).
        *   `\f`: Switch to "Flagged" messages.
        *   `\u`: Switch to "Unread" messages across all accounts.

4.  **Unsubscribe Action**
    *   **Improvement:** Bind a key (e.g., `U`) to parse the `List-Unsubscribe` header and either open the URL or generate the unsubscribe email automatically.

## Feature & General Improvements

1.  **Address Book Integration (`khard`)**
    *   **Current:** Manual alias file `~/.config/mutt/aliases`.
    *   **Improvement:** Integrate `khard` (CLI CardDAV client) for robust contact management and autocompletion.
    *   **Action:** Install `khard` and set `query_command = "khard email --parsable '%s'"` in `muttrc`.

2.  **Fuzzy Search (`fzf`)**
    *   **Improvement:** Integrate `fzf` for fuzzy searching mailboxes or selecting contacts.
    *   **Action:** Create a macro that pipes the mailbox list or alias list to `fzf` and acts on the selection (change folder or insert address).

3.  **Sending Backend (`msmtp`)**
    *   **Current:** Uses `smtp_authenticators` (Internal SMTP).
    *   **Improvement:** Switch to `msmtp` for more robust multi-account sending management, queuing (offline sending), and easier debugging.
    *   **Action:** Configure `~/.msmtprc` and set `set sendmail = "/usr/bin/msmtp"` in `muttrc`.

4.  **GPG Encryption/Signing**
    *   **Current:** `mutt/crypto` directory exists but is empty.
    *   **Improvement:** Configure GPG to allow signing and encrypting emails. This adds a layer of security and identity verification.
    *   **Action:** Populate `mutt/crypto/gpg.rc` with GPG command definitions and source it in `muttrc`.

5.  **Desktop Notifications**
    *   **Current:** Visual beep/sound.
    *   **Improvement:** Trigger system notifications (e.g., `notify-send`) when new important mail arrives.
    *   **Action:** Set `new_mail_command` to a script that filters for priority mail and sends a desktop notification.

6.  **Spam Handling Macro**
    *   **Improvement:** A dedicated macro to move a message to the Spam folder (and potentially train a filter if one were running locally).
    *   **Action:** `macro index S "<save-message>=[Gmail]/Spam<enter>"` (Account dependent).
