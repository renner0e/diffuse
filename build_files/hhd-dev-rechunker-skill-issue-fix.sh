#!/usr/bin/env bash

set -ouex pipefail

tee /usr/bin/rechunker-group-fix <<'EOF'
#!/bin/sh
cat /usr/lib/sysusers.d/*.conf | grep -e "^g" | grep -v -e "^#" | awk "NF" | awk '\''{print $2}'\'' | grep -v -e "wheel" -e "root" -e "sudo" | xargs -I{} sed -i "/{}/d" $1'
EOF
chmod +x /usr/bin/rechunker-group-fix
tee /usr/lib/systemd/system/rechunker-group-fix.service <<'EOF'
[Unit]
Description=Fix groups
Wants=local-fs.target
After=local-fs.target

[Service]
Type=oneshot
ExecStart=rechunker-group-fix /etc/group
ExecStart=rechunker-group-fix /etc/gshadow
ExecStart=systemd-sysusers

[Install]
WantedBy=default.target multi-user.target
EOF
systemctl enable rechunker-group-fix.service
