local function ensure_installed(tool, install_cmds)
  -- Check if the tool is already installed
  local handle = io.popen(tool .. " --version 2>/dev/null")
  local result = handle:read("*a")
  handle:close()

  if result == "" then
    print("Installing " .. tool .. "...")
    
    -- Detect the platform
    local uname_handle = io.popen("uname -s")
    local os_name = uname_handle:read("*l")
    uname_handle:close()

    local install_cmd = install_cmds.default -- Default command as fallback

    -- macOS
    if os_name == "Darwin" then
      install_cmd = install_cmds.macos
    else
      -- Determine the Linux distribution
      local distro_handle = io.popen("cat /etc/os-release 2>/dev/null | grep '^ID=' | cut -d '=' -f 2")
      local distro = distro_handle:read("*l")
      distro_handle:close()

      -- Match the distro to its respective package manager
      if distro == "ubuntu" or distro == "debian" then
        install_cmd = install_cmds.debian
      elseif distro == "fedora" then
        install_cmd = install_cmds.fedora
      elseif distro == "arch" or distro == "manjaro" then
        install_cmd = install_cmds.arch
      end
    end

    -- Execute the installation command
    local status = os.execute(install_cmd)
    if status ~= 0 then
      print("Error installing " .. tool)
    end
  end
end

-- Example usage
ensure_installed("shellcheck", {
  macos = "brew install shellcheck",
  debian = "sudo apt-get install -y shellcheck",
  fedora = "sudo dnf install -y shellcheck",
  arch = "sudo pacman -S --noconfirm shellcheck",
  default = "echo 'Please install shellcheck manually.'"
})

ensure_installed("shfmt", {
  macos = "brew install shfmt",
  debian = "sudo apt-get install -y shfmt",
  fedora = "sudo dnf install -y shfmt",
  arch = "sudo pacman -S --noconfirm shfmt",
  default = "go install mvdan.cc/sh/v3/cmd/shfmt@latest"
})

ensure_installed("fzf", {
  macos = "brew install fzf",
  debian = "sudo apt-get install -y fzf",
  fedora = "sudo dnf install -y fzf",
  arch = "sudo pacman -S --noconfirm fzf",
  default = "echo 'Please install fzf manually.'"
})

ensure_installed("rustfmt", {
  macos = "rustup component add rustfmt",
  debian = "rustup component add rustfmt",
  fedora = "sudo dnf install -y rustfmt",
  arch = "rustup component add rustfmt",
  default = "rustup component add rustfmt"
})
