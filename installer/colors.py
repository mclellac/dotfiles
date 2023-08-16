from termcolor import colored

GRAY = lambda msg: colored(msg, "white")
WHITE = lambda msg: colored(msg, "white", attrs=["bold"])
RED = lambda msg: colored(msg, "red")
GREEN = lambda msg: colored(msg, "green")
YELLOW = lambda msg: colored(msg, "yellow")
CYAN = lambda msg: colored(msg, "cyan")
BLUE = lambda msg: colored(msg, "blue")

def color_wrap(ansicode):
    return lambda msg: ansicode + str(msg) + "\033[0m"
