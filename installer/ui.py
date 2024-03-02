from rich.console import Console
from rich.text import Text

console = Console()


def message_box(msg, color="white", use_bold=False, style=None):
    """
    Displays a message box with the given message.

    Args:
        msg (str): The message to be displayed in the message box.
        color (str, optional): The color of the message box. Defaults to "white".
        use_bold (bool, optional): Whether to use bold style for the message box. Defaults to False.
        style (str, optional): The style of the message box. If not provided, the color will be used.

    Returns:
        None

    Example usage:
        message_box("Post Install Actions", style="warning", use_bold=True)
    """

    # If style is provided, use it; otherwise, use color
    style = style if style is not None else color

    # Adjust the width to 80 characters
    box_width = 80

    # Split the message into multiple lines if it's too long
    lines = []
    words = msg.split()
    current_line = ""
    for word in words:
        if len(current_line) + len(word) + 1 <= 50:  # Maximum line length is 50 characters
            current_line += " " + word
        else:
            lines.append(current_line)
            current_line = word
    if current_line:
        lines.append(current_line)

    # Calculate padding for centering the message
    pad_width = (box_width - max(len(line) for line in lines)) // 2

    # Construct the message box
    box_lines = [
        "┏" + ("━" * box_width) + "┓",
        *["┃" + " " * pad_width + line.ljust(box_width - pad_width * 2) + " " * pad_width + "┃" for line in lines],
        "┗" + ("━" * box_width) + "┛",
    ]

    # Join the box lines and print the message
    box_msg = "\n".join(box_lines)
    text = Text(box_msg, style=f"bold {style}" if use_bold else style)
    console.print(text)
