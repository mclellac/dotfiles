#!/usr/bin/env python

import subprocess
import yaml
from rich.console import Console
from rich.progress import Progress

console = Console()

def is_package_installed(package: str, package_manager: str) -> bool:
    """Check if a package is installed using the appropriate package manager."""
    try:
        if package_manager == "dnf":
            result = subprocess.run(["dnf", "list", "installed", package], capture_output=True, text=True)
            return package in result.stdout
        elif package_manager == "pacman":
            result = subprocess.run(["pacman", "-Qq", package], capture_output=True, text=True)
            return package in result.stdout
        elif package_manager == "apt":
            result = subprocess.run(["dpkg", "-l", package], capture_output=True, text=True)
            return f"ii  {package}" in result.stdout
        elif package_manager == "homebrew":
            result = subprocess.run(["brew", "list", "--formula", package], capture_output=True, text=True)
            return package in result.stdout
        elif package_manager == "pip":
            result = subprocess.run(["pip", "show", package], capture_output=True, text=True)
            return "Name: " + package in result.stdout
        else:
            console.print(f"[bold red]Error:[/bold red] Unsupported package manager: {package_manager}")
            return False
    except subprocess.CalledProcessError:
        return False
    except FileNotFoundError:
        console.print("[bold red]Error:[/bold red] {} not found. Please make sure it is installed.".format(package_manager))
        return False

def install_packages(packages: list, package_manager: str) -> None:
    """Install packages using the appropriate package manager."""
    
    try:
        not_installed = [pkg for pkg in packages if not is_package_installed(pkg, package_manager)]
        if not_installed:
            console.print(f"[bold green]{package_manager} packages to be installed:[/bold green]")
            for pkg in not_installed:
                console.print(f"  - [green3]{pkg}[/green3]")

        if not_installed:
            if package_manager == "dnf":
                subprocess.run(["sudo", "dnf", "install", "-y"] + not_installed, check=True)
            elif package_manager == "pacman":
                subprocess.run(["sudo", "pacman", "-S", "--noconfirm"] + not_installed, check=True)
            elif package_manager == "apt":
                subprocess.run(["sudo", "apt", "install", "-y"] + not_installed, check=True)
            elif package_manager == "homebrew":
                subprocess.run(["brew", "install"] + not_installed, check=True)
            elif package_manager == "pip":
                subprocess.run(["pip", "install"] + not_installed, check=True)
            else:
                console.print(f"[bold red]Error:[/bold red] Unsupported package manager: {package_manager}")
        else:
            console.print(f"[bold green]All {package_manager} packages have already been installed.[/bold green]")
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Error:[/bold red] Failed to install packages with {package_manager}: {e}")

def is_copr_repo_enabled(repo_name: str) -> bool:
    """Check if a COPR repository is enabled."""
    try:
        result = subprocess.run(["sudo", "dnf", "repolist"], capture_output=True, text=True, check=True)
        repo_list = result.stdout.splitlines()
        for repo in repo_list:
            if f":{repo_name}:" in repo:
                return True
        return False
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Error:[/bold red] Failed to check if COPR repository {repo_name} is enabled: {e}")
        return False
    except FileNotFoundError:
        console.print("[bold red]Error:[/bold red] dnf not found. Please make sure it is installed.")
        return False

def enable_copr_repo(repo_name: str) -> None:
    """Enable a COPR repository."""
    if not is_copr_repo_enabled(repo_name):
        try:
            subprocess.run(["sudo", "dnf", "copr", "enable", repo_name, "-y"], check=True)
            console.print(f"[green]COPR repository {repo_name} successfully enabled[/green]")
        except subprocess.CalledProcessError as e:
            console.print(f"[bold red]Error:[/bold red] Failed to enable COPR repository: {e}")
    else:
        console.print(f"[green]COPR repository {repo_name} is already enabled[/green]")

def main() -> None:
    try:
        with open("packages.yaml", "r", encoding="utf-8") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        console.print("[bold red]Error:[/bold red] packages.yaml not found. Please make sure the file exists.")
        return

    current_os = None

    try:
        subprocess.run(["brew", "--version"], capture_output=True, text=True, check=True)
        current_os = "darwin"
    except FileNotFoundError:
        try:
            import distro
            current_os = distro.id().lower()
        except ImportError:
            console.print("[bold red]Error:[/bold red] Unable to determine the operating system.")
            return

    if current_os in config:
        os_config = config[current_os]
        dnf_packages = os_config.get("dnf", [])
        pacman_packages = os_config.get("pacman", [])
        apt_packages = os_config.get("apt", [])
        brew_packages = os_config.get("brew", [])
        pip_packages = os_config.get("pip-packages", [])
        copr_repo = os_config.get("copr-repo", {}).get("name")

        if current_os == "fedora":
            if copr_repo:
                enable_copr_repo(copr_repo)
            with Progress() as progress:
                task = progress.add_task("[cyan]Checking package installation...", total=len(dnf_packages))
                for pkg in dnf_packages:
                    is_package_installed(pkg, "dnf")
                    progress.update(task, advance=1, description=f"Checking {pkg}")
            install_packages(dnf_packages, "dnf")
        elif current_os == "arch":
            with Progress() as progress:
                task = progress.add_task("[cyan]Checking package installation...", total=len(pacman_packages))
                for pkg in pacman_packages:
                    is_package_installed(pkg, "pacman")
                    progress.update(task, advance=1, description=f"Checking {pkg}")
            install_packages(pacman_packages, "pacman")
        elif current_os in ["debian", "kali", "ubuntu"]:
            with Progress() as progress:
                task = progress.add_task("[cyan]Checking package installation...", total=len(apt_packages))
                for pkg in apt_packages:
                    is_package_installed(pkg, "apt")
                    progress.update(task, advance=1, description=f"Checking {pkg}")
            install_packages(apt_packages, "apt")
        elif current_os == "darwin":
            pip_packages = []
            with Progress() as progress:
                task = progress.add_task("[cyan]Checking package installation...", total=len(brew_packages))
                for pkg in brew_packages:
                    is_package_installed(pkg, "homebrew")
                    progress.update(task, advance=1, description=f"Checking {pkg}")
            install_packages(brew_packages, "homebrew")

    install_packages(pip_packages, "pip")

if __name__ == "__main__":
    main()
