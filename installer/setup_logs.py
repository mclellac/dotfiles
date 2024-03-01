"""
This module contains functions for setting up and logging messages with rich.

Functions:
    setup_logging: Configures the logging module with a basic configuration.
    log: Logs a message with optional action title, style, and console.
"""

import logging
from rich.text import Text
from rich.logging import RichHandler


def setup_logging():
    """
    Set up logging configuration.

    This function configures the logging module with a basic configuration.
    It sets the logging level to INFO, the format to only display the log message,
    and adds a RichHandler to enable rich tracebacks.

    """
    logging.basicConfig(level=logging.INFO, format="%(message)s", handlers=[RichHandler(rich_tracebacks=True)])


def log(message, action_title=None, style=None, console=None):
    """
    Logs a message with optional action title, style, and console.

    Args:
        message (str): The message to be logged.
        action_title (str, optional): The title of the action. Defaults to None.
        style (str, optional): The style of the message. Defaults to None.
        console (object, optional): The console object to print the message. Defaults to None.
    """
    logger = logging.getLogger()

    if action_title:
        message = f"{action_title}: {message}"

    if style:
        message = Text(message, style=style)

    # If console is provided, use it to print the message
    if console is not None:
        console.print(message)
    else:
        logger.info(message)
