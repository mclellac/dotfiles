import logging
import sys

def setup_logging():
    logging.basicConfig(format="%(message)s", stream=sys.stdout, level=logging.INFO)


def log(msg, color=None, cr=True, action_title=None, errors=None):
    """
    Log a message with optional color, action title, error handling, and newline control.

    Args:
        msg (str): The message to log.
        color (callable, optional): A color formatting function to apply to the message.
                                    For example: color_wrap("\033[0;31m") to make the message red.
        cr (bool, optional): Whether to add a newline after logging the message. Default is True.
        action_title (str, optional): Title of the action associated with the message.
        errors (list, optional): A list to append errors or messages along with their action titles.

    Examples:
        log("Regular log message")
        log("Colored log message", color=RED)
        log("Error message", color=RED, action_title="My Action")
        log("Error message with continue", color=RED, action_title="My Action", errors=[])

    """
    if color:
        msg = color(msg)

    if action_title:
        msg = f"{action_title}: {msg}"

    logging.info(msg)

    if errors is not None and action_title is not None:
        errors.append((action_title, msg))

    if cr:
        logging.info("")