#!/usr/bin/env python3
import os
import sys

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    root = os.path.expanduser(sys.argv[1])
    mailboxes = []

    if not os.path.exists(root):
        return

    # Walk the directory tree
    for dirpath, dirnames, filenames in os.walk(root):
        # Sort dirnames to ensure deterministic output order
        dirnames.sort()

        # Check if this directory is a Maildir (contains 'cur')
        if 'cur' in dirnames:
            relpath = os.path.relpath(dirpath, root)
            if relpath != '.':
                # Escape double quotes in the path
                safe_path = relpath.replace('"', '\\"')
                # Format as "=\"Path/To/Mailbox\"" for Neomutt
                # The '=' expands to the defined $folder
                mailboxes.append(f'"={safe_path}"')

            # Do not traverse into the Maildir internal directories
            # We modify dirnames in place to prune the walk
            if 'cur' in dirnames: dirnames.remove('cur')
            if 'new' in dirnames: dirnames.remove('new')
            if 'tmp' in dirnames: dirnames.remove('tmp')

    # Sort the final list of mailboxes alphabetically
    mailboxes.sort()

    # Print as a single space-separated line
    print(" ".join(mailboxes))

if __name__ == "__main__":
    main()
