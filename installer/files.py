import os
import shutil
from os import makedirs
from rich.console import Console

console = Console()


def copy_files_or_directories(target, source, args):
    if not os.path.lexists(source):
        console.print("[red]source {} : does not exist[/red]".format(source))
        return

    if os.path.lexists(target):
        if args.force:
            if os.path.isfile(target):
                os.remove(target)
            else:
                shutil.rmtree(target)
        else:
            console.print(
                "{:80s} : {}".format(
                    "[blue]" + target + "[/blue]",
                    (
                        "[gray]already exists, skipped[/gray]"
                        if os.path.isfile(target)
                        else "[yellow]exists, but not a file or directory. Check for yourself!![/yellow]"
                    ),
                ),
                style="bold",
            )

    if not os.path.lexists(target):
        mkdir_target = os.path.split(target)[0]
        makedirs(mkdir_target, exist_ok=True)
        if os.path.isfile(source):
            shutil.copy2(source, target)
        else:
            shutil.copytree(source, target)
        console.print(
            "[blue]{}[/blue] [cyan]━━[/cyan] [green]'{}'[/green]".format(source, target),
            style="bold",
        )
