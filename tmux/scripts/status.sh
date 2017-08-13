zsh_detect_openshift() {
    typeset -AH environments

    if [[ $(grep -E '(^domain|^search)' /etc/resolv.conf) =~ ${WORK_DOMAIN} ]]; then
       
        if  type oc > /dev/null; then
            local ose_logged_in=$((oc get projects) 2>&1)
            local color='%F{red}'

            if [[ $ose_logged_in =~ "^NAME" ]]; then
                local ose_prj=$(oc project | awk -F'"' '$0=$2')
                local ose_env=$(oc project | awk -F'"' '$0=$4'| cut -d"." -f2 | awk '{print toupper($0)}')

                if [ -n "${ose_env}" ]; then
                    case "${ose_env}" in
                        *NM*)
                            current_state="prod"
                        ;;
                        *DEV*)
                            current_state="devel"
                        ;;
                    esac
                fi

                echo -n "%{$color%}\uE7B7 ${current_state}%F{125}::%{$color%}${ose_prj}" 
            elif [[ $ose_logged_in =~ "^error|^Error" ]]; then
                echo -n "%F{grey%}\uE7B7"
            fi
        fi
    fi
}
