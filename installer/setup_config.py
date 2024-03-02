import sys
import yaml
from .setup_logs import log
from rich.console import Console

console = Console()


def load_config(filename):
    try:
        with open(filename, "r", encoding="utf-8") as file:
            config = yaml.safe_load(file)
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
