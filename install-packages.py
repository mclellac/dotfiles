#!/usr/bin/env python

import subprocess
import yaml


def install_packages_with_dnf(packages):
    for package in packages:
        subprocess.run(["sudo", "dnf", "install", package, "-y"])


def install_packages_with_pip(packages):
    for package in packages:
        subprocess.run(["pip", "install", package])


def enable_copr_repo(repo_name):
    subprocess.run(["sudo", "dnf", "copr", "enable", repo_name, "-y"])


def main():
    # Read package information from YAML file
    with open("packages.yaml", "r") as f:
        config = yaml.safe_load(f)

    dnf_packages = list(config["fedora"].keys())
    pip_packages = list(config["pip-packages"].keys())
    copr_repo = config["copr-repo"]["name"]

    install_packages_with_dnf(dnf_packages)
    install_packages_with_pip(pip_packages)
    enable_copr_repo(copr_repo)
    subprocess.run(["sudo", "dnf", "install", "lazygit"])


if __name__ == "__main__":
    main()
