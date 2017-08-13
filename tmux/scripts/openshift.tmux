#1/usr/bin/env zsh


# First check if we're able to reach OpenShift by checking if /etc/resolv.conf 
# search/domain line includes our VPN, WiFi, or BAN domains. 
# (Set $WORK_DOMAIN variable in ~/.zprivate)
if [[ $(grep -E '(^domain|^search)' /etc/resolv.conf) =~ ${WORK_DOMAIN} ]]; then
    # if it does; check if oc command exists
    if  type oc > /dev/null; then
        local ose_logged_in=$((oc get projects) 2>&1)
        local color='%F{red}'

        # Now we'll check if we're currently logged in or not. If so, get the info we want.
        if [[ $ose_logged_in =~ "^NAME" ]]; then
            local ose_prj=$(oc project | awk -F'"' '$0=$2')
            local ose_env=$(oc project | awk -F'"' '$0=$4'| cut -d"." -f2 | awk '{print toupper($0)}')

            # The above cut will end up being either DEV or NM. NM is our prod environment so we will
            # rename it here.               
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

            echo -n "%{$color%}\uE7B7 ${current_state}%F{125}::%{$color%}${ose_prj}" # '\uE7BB' (glyph for RH logo)
        elif [[ $ose_logged_in =~ "^error|^Error" ]]; then
            # Not logged in, but on the corporate network? Display OShift glyph as grey.
            echo -n "%F{grey%}\uE7B7"
        fi
    fi
fi

