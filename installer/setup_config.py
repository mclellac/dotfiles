import sys
import yaml
from .ui import message_box
from .setup_logs import log
from .colors import YELLOW


def load_config(filename):
    try:
        with open(filename, "r") as file:
            config = yaml.safe_load(file)
            message_box("YAML config opened.", color=YELLOW)
            return config
    except FileNotFoundError:
        log(f"Config file '{filename}' not found.")
        sys.exit(1)
    except yaml.YAMLError as e:
        log(f"Error parsing config file '{filename}': {e}")
        sys.exit(1)
    except Exception as e:
        log(f"An unexpected error occurred while loading config file '{filename}': {e}")
        sys.exit(1)
