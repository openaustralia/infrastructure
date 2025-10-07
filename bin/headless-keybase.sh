#!/bin/sh
run_keybase -k
keybase ctl autostart --disable
systemctl --user set-environment KEYBASE_AUTOSTART=1

for service in keybase kbfs keybase-redirector; do
    systemctl --user enable "${service}.service"
    systemctl --user start "${service}.service"
done

if (systemctl --user --no-pager status keybase kbfs keybase-redirector >/dev/null); then
    echo "Keybase services seem to be running"
else
    echo "Keybase services don't seem to be running."
    systemctl --user status keybase kbfs keybase-redirector
    exit 1
fi

echo "The following should show your Keybase identity.:"
keybase id
echo
echo "If your identiy is not shown, please run 'keybase unlock'"
