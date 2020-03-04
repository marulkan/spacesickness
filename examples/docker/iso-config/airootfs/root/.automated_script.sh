#!/bin/bash

script_cmdline ()
{
    local param
    for param in $(< /proc/cmdline); do
        case "${param}" in
            script=*) echo "${param#*=}" ; return 0 ;;
        esac
    done
}

restart_dhcp ()
{
    IFACES=$(ip link show | grep -v '^ ' | awk '{ print $2 }' | cut -d':' -f1 | grep '^e' | sort)
    SORTED_IFACES=$(for i in ${IFACES}; do udevadm info -e | grep "^P.*${i}"; done | cut -d"/" -f5- | sort | awk -F"/" '{print $NF }')
    ITER=0
    for i in $SORTED_IFACES; do
        if (( "$ITER" >= "1" )); then
            break
        fi
        systemctl restart dhcpcd@${i}.service
        let ITER=ITER+1
    done
}

run_in_tmux ()
{
    # tmux new-session -s "setup" "sh /tmp/startup_script; reboot"
    tmux new-session -s "setup" "sh /tmp/startup_script"
}

automated_script ()
{
    local script rt
    script="$(script_cmdline)"
    if [[ -n "${script}" && ! -x /tmp/startup_script ]]; then
        if [[ "${script}" =~ ^http:// || "${script}" =~ ^ftp:// || "${script}" =~ ^https:// ]]; then
            wget "${script}" --no-check-certificate --retry-connrefused -q -O /tmp/startup_script >/dev/null
            rt=$?
        else
            cp "${script}" /tmp/startup_script
            rt=$?
        fi
        if [[ ${rt} -eq 0 ]]; then
            chmod +x /tmp/startup_script
            run_in_tmux
        fi
    fi
}

if [[ $(tty) == "/dev/tty1" ]]; then
    # remove floppy here since it's too complicated to do in the iso-build process.
    rmmod floppy
    # restart dhcpcd since it breaks at boot
    restart_dhcp
    automated_script
fi

