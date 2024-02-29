import os
import shutil
from installer.colors import RED, GREEN, YELLOW, CYAN, BLUE, GRAY
from installer.setup_logs import log
from os import makedirs


def copy_files_or_directories(target, source, args):
    # bad entry if source does not exist...
    if not os.path.lexists(source):
        log(RED("source %s : does not exist" % source))
        return

    # if --force option is given, delete and override the previous copy
    if os.path.lexists(target):
        if args.force:
            if os.path.isfile(target):
                os.remove(target)
            else:
                shutil.rmtree(target)
        else:
            log(
                "{:80s} : {}".format(
                    BLUE(target),
                    GRAY("already exists, skipped")
                    if os.path.isfile(target)
                    else YELLOW(
                        "exists, but not a file or directory. Check for yourself!!"
                    ),
                ),
                cr=False,
            )

    # copy file or directory if available
    if not os.path.lexists(target):
        mkdir_target = os.path.split(target)[0]
        makedirs(mkdir_target, exist_ok=True)
        if os.path.isfile(source):
            shutil.copy2(source, target)
        else:
            shutil.copytree(source, target)
        log(
            "{:20s} {} {}".format(BLUE(source), CYAN("━━"), GREEN("'%s'" % target)),
            cr=False,
        )
