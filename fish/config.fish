# Fish shell configuration

# Set environment variables
set -x STARSHIP_CONFIG ~/.config/starship/custom.toml
set -x LANG "en_US.UTF-8"
set -x TERM "xterm-256color"
set -x GO111MODULE on
set -x GOPATH "$HOME/Projects"
set -x GOROOT "/usr/local/opt/go/libexec"
set -x DENO_INSTALL "$HOME/.deno"

# Set paths
set -x PATH "/usr/local/opt/llvm/bin" "$HOME/.config/emacs/bin" "$HOME/.local/bin" "/usr/local/opt/yq@3/bin" "$PATH"
set -x PATH "$GOPATH/bin" "$GOROOT/bin" "$PATH"
set -x PATH "$DENO_INSTALL/bin" "$PATH"
if test -d /usr/local/opt/curl/bin
    set -x PATH /usr/local/opt/curl/bin $PATH
end
if test -d "$HOME/Library/Python/3.10/bin"
    set -x PATH "$HOME/Library/Python/3.10/bin" "$PATH"
end
if test -d "$HOME/.cargo/bin"
    set -x PATH "$HOME/.cargo/bin" "$PATH"
end


# Aliases
alias ls 'ls -G'
alias vim 'nvim'
alias msfconsole 'msfconsole -x "db_connect postgres@msf"'
alias diff 'colordiff'
alias python 'python3'
alias ll 'ls -alG'
alias gitlog "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gitstatus 'git status -uno'
alias history 'history 0'
alias agenda 'gcalcli agenda'
alias calw 'clear; gcalcli calw -w 12'
alias calm 'clear; gcalcli calm -w 20'
alias hd 'od -Ax -tx1 -v'
alias ccat 'ccat -G String="brown" -G Keyword="darkblue" -G Comment="lightgrey" -G Type="teal" -G Literal="teal" -G Punctuation="darkred" -G Plaintext="darkblue" -G Tag="blue" -G HTMLTag="lightgreen" -G HTMLAttrName="blue" -G HTMLAttrValue="green" -G Decimal="darkblue"'
alias mutt 'neomutt'
alias grep 'grep --color'
alias podls 'echo "Pods running in current context, and the container images inside them" && kubectl get pods --all-namespaces -o=jsonpath=\'{range .items[*]}{"\\n"}{.metadata.name}{":\\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}\' | grep -E -v \'(fluent|heap|l7|kube)\' | sed \'s/;$//\' | sort'
alias nmap-scripts-dir 'cd /usr/share/nmap/scripts'
alias ose_services 'oc get services --all-namespaces --template \'{{range .items}}{{if ne .spec.clusterIP "None"}}{{.metadata.name}} {{.metadata.namespace}} {{.spec.clusterIP}} {{(index .spec.ports 0).protocol}} {{(index .spec.ports 0).port}}{{"\\n"}}{{end}}{{end}}\' | sed  -e \'s/^/ ⎈ /g\' -e \'s/ TCP / tcp → /g\' -e \'s/ UDP / udp → /g\''
alias ose_pods 'oc get pods --all-namespaces --template \'{{range .items}}{{if .status.containerStatuses}}{{if (index .status.containerStatuses 0).ready}}{{if not .spec.hostNetwork}}{{.spec.nodeName}} {{.status.hostIP}} {{.metadata.name}} {{.metadata.namespace}} {{.status.podIP}} {{printf "%.21s" (index .status.containerStatuses 0).containerID}}{{"\\n"}}{{end}}{{end}}{{end}}{{end}}\' | sed -e \'s|docker://||\''
alias cputop 'top -bc -d 60 -n 5'
if command -v lvim >/dev/null 2>&1
    alias vim lvim
else if command -v nvim >/dev/null 2>&1
    alias vim nvim
end

# Functions
function digans
    dig "$argv" +noall +answer
end

function digsoa
    dig "$argv" SOA +noall +answer
end

function digmx
    dig "$argv" MX +noall +answer
end

function digns
    dig "$argv" NS +noall +answer
end

function digany
    dig "$argv" ANY +noall +answer
end

function kubepass
    kubectl config view -o jsonpath='{.users[?(@.name == "'"$argv"'")].user.password}'
end

function kubectx
    kubectl config current-context
end

function kubeip
    kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
end

function showcert
    echo "openssl s_client -showcerts -connect $argv"
    echo -n | openssl s_client -showcerts -connect $argv
end

function ssldump
    set NIC $argv[1]
    set PORT $argv[2]
    sudo tcpdump -ni $NIC "tcp port $PORT and (tcp[((tcp[12] & 0xf0) >> 2)] = 0x16)" -vvvv
end

function check_compression
    curl -s -I -H 'Accept-Encoding: br,gzip,deflate' $argv | grep -i "Content-Encoding"
end

function cmdhist
    history | awk '{print $2}' | sort | uniq -c | sort -rn | head -20 | sed 's/.\///g' | awk '!max{max=$1;}{r=""; i=s=60 * $1/max; while(i-->0) r=r"█"; printf "\033[1;34m %15s \033[0m %4d \033[1;36m %s \033[0m %s", $2, $1, r, "\n";}'
end

function connerize
    echo "connery: $argv" | sed -e "s/s/sh/g" -e "s/shsh/sh/g" -e "s/shh/sh/g"
end

function connerize-say
    echo "$argv" | sed -e "s/s/sh/g" -e "s/shsh/sh/g" -e "s/shh/sh/g" | say -v "Alex" -i -r 200
end

function akcurl
    set -l headers "Pragma: akamai-x-get-request-id,akamai-x-get-cache-key,akamai-x-cache-on,akamai-x-cache-remote-on,akamai-x-get-true-cache-key,akamai-x-check-cacheable,akamai-x-get-extracted-values,akamai-x-feo-trace,x-akamai-logging-mode: verbose"
    echo "curl -sIXGET \"$argv\" -H \"$headers\""
    curl -sIXGET "$argv" -H "$headers"
end

function cache-key-curl
    set -l headers "Pragma: akamai-x-get-cache-key,akamai-x-get-true-cache-key,akamai-x-check-cacheable"
    echo "curl -sIXGET \"$argv\" -H \"$headers\""
    curl -sIXGET "$argv" -H "$headers"
end

function akhttp
  set -l headers '"Pragma: akamai-x-get-request-id,akamai-x-get-cache-key,akamai-x-cache-on,akamai-x-cache-remote-on,akamai-x-get-true-cache-key,akamai-x-check-cacheable,akamai-x-get-extracted-values,akamai-x-feo-trace,x-akamai-logging-mode: verbose"'
  echo "http --headers \"$argv\" $headers"
  http --headers "$argv" $headers
end

function aklab
    set -l AKFLAGS "-H \"Pragma: akamai-x-cache-on, akamai-x-cache-remote-on, akamai-x-check-cacheable, akamai-x-get-cache-key, akamai-x-get-ssl-client-session-id, akamai-x-get-true-cache-key, akamai-x-get-request-id\" -H \"x-akamai-logging-mode: verbose\" -vv -H \"User-Agent: AU-KSD\""
    curl -I $AKFLAGS "$argv"
end

function calc
    set -l result (printf "scale=10;%s\n" "$argv" | bc --mathlib | tr -d '\\\n')
    if string match -q ".*\\..*" $result
        printf "%s" $result | sed -e 's/^\./0./' -e 's/^-\./-0./' -e 's/0*$//;s/\.$//'
    else
        printf "%s" $result
    end
    printf "\n"
end


# FZF
set -x FZF_DEFAULT_OPTS "
	--color=fg:#797593,bg:#faf4ed,hl:#d7827e
	--color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
	--color=border:#dfdad9,header:#286983,gutter:#faf4ed
	--color=spinner:#ea9d34,info:#56949f
	--color=pointer:#907aa9,marker:#b4637a,prompt:#797593"

# Starship
starship init fish | source

# iTerm2 Shell Integration
if test -e "$HOME/.iterm2_shell_integration.fish"
   source "$HOME/.iterm2_shell_integration.fish"
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc' ];
    source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc';
end
