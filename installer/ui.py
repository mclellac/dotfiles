from installer.colors import WHITE
from installer.setup_logs import log

def message_box(msg, color=WHITE, use_bold=False):
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

    # Join the box lines and log the message
    box_msg = "\n".join(box_lines)
    if use_bold:
        log(box_msg, color=color, cr=False)
    else:
        log(box_msg, color=color, cr=False)
