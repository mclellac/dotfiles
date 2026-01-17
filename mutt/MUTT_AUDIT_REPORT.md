# Neomutt Configuration Audit Report

## 1. Overview
This report analyzes the current `neomutt` configuration located in the `mutt/` directory. The audit focuses on configuration structure, potential issues, feature enhancements, and dependency requirements.

## 2. Notification Fix
**Issue:** New email notifications required manual dismissal.
**Fix Applied:** The `mutt/scripts/notify_mail.sh` script was updated to use `notify-send -t 3000`. This ensures notifications automatically expire and disappear after 3 seconds.

## 3. Configuration Analysis

### 3.1 Unused Files
*   **`mutt/formats`**: This file contains `status_format`, `index_format`, `pager_format`, and others. However, it is **not sourced** in `muttrc`.
    *   *Current State:* `muttrc` sources `colors` (which sets a pill-style `status_format`) and defines its own formats inline (though some might be overridden).
    *   *Recommendation:* Review `mutt/formats`. If it contains desired settings, source it in `muttrc`. If it is obsolete, delete it to avoid confusion.

### 3.2 Hardcoded Gmail Paths
*   **`binds.muttrc`**: The macro `macro index S "<save-message>=[Gmail]/Spam<enter>"` hardcodes the Spam folder to `[Gmail]/Spam`.
    *   *Risk:* This will fail for non-Gmail accounts (e.g., standard IMAP/Maildir where the spam folder might be `Junk` or `Spam`).
*   **`acct/personal`**: Sets `trash = "+[Gmail]/Trash"`.
    *   *Observation:* This explicitly ties the personal account to a Gmail-style folder structure.

### 3.3 Folder Naming Inconsistency
*   In `acct/personal`:
    *   `postponed = "+Drafts"` (Standard naming)
    *   `trash = "+[Gmail]/Trash"` (Gmail naming)
    *   *Recommendation:* Ensure the local Maildir synchronization (`mbsync`/`offlineimap`) maps these correctly. If `mbsync` is configured to flatten folders or map `[Gmail]/Trash` to `Trash`, the config should reflect the *local* path.

### 3.4 "No Perl" Compliance
*   **Status:** **Compliant.**
*   The `display_filter` in `muttrc` which previously used a complex Perl one-liner is commented out.
*   `mailcap` uses `w3m` for HTML rendering, avoiding Perl-based tools.
*   Helper scripts in `mutt/scripts/` are primarily Python (`.py`) or Bash (`.sh`).

## 4. Dependencies
The following external tools are referenced in the configuration and must be installed for full functionality:

*   **Core:** `neomutt`, `notmuch` (for indexing/search), `msmtp` (for sending).
*   **Helpers:**
    *   `khard` (Address book query in `muttrc`)
    *   `urlscan` (URL extraction in `binds.muttrc`)
    *   `fzf` (Fuzzy finding folders in `binds.muttrc`)
    *   `w3m` (HTML email rendering in `mailcap`)
    *   `mpv` (Video playback in `mailcap`)
    *   `pandoc` (Markdown to HTML conversion in `muttrc` macro)
    *   `git-split-diffs` (Patch viewing macro in `muttrc`)
    *   `aspell` (Spell checking in `acct/personal`)
    *   `python3` (Used by `find_mailboxes.py` and calendar scripts)

## 5. Recommendations
1.  **Cleanup:** Remove `mutt/formats` if it is indeed unused.
2.  **Robustness:** Update the Spam macro to use a folder-hook or a variable that changes based on the active account, rather than hardcoding `[Gmail]/Spam`.
3.  **Docs:** Ensure `mbsyncrc` (not analyzed here, but implied) matches the folder expectations in `acct/personal`.
