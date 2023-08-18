import os
from installer.colors import RED, GREEN, YELLOW, CYAN, BLUE, GRAY
from installer.setup_logs import log
from os import makedirs


def create_symbolic_link(target, source, args):
    # bad entry if source does not exist...
    if not os.path.lexists(source):
        log(RED("source %s : does not exist" % source))
        return

    # if --force option is given, delete and override the previous symlink
    if os.path.lexists(target):
        is_broken_link = os.path.islink(target) and not os.path.exists(os.readlink(target))

        if args.force or is_broken_link:
            if os.path.islink(target):
                os.unlink(target)
            else:
                log(
                    "{:60s} : {}".format(
                        BLUE(target), YELLOW("already exists but not a symlink; --force option ignored")
                    ),
                    cr=False,
                )
        else:
            log(
                "{:60s} : {}".format(
                    BLUE(target),
                    GRAY("already exists, skipped")
                    if os.path.islink(target)
                    else YELLOW("exists, but not a symbolic link. Check by yourself!!"),
                ),
                cr=False,
            )

    # make a symbolic link if available
    if not os.path.lexists(target):
        mkdir_target = os.path.split(target)[0]
        makedirs(mkdir_target, exist_ok=True)
        log(GREEN("Created directory : %s" % mkdir_target))
        os.symlink(source, target)
        log("{:20s} {} {}".format(BLUE(target), CYAN("━━"), GREEN("'%s'" % source)), cr=False)
