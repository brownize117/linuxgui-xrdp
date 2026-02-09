xrdp-sesman </dev/null >/dev/null 2>&1 &
xrdp -nodaemon </dev/null >/dev/null 2>&1 &
echo "Can open Google Chrome by execute \" ggcr \" on remote terminal"
echo "XRDP run at port 3389"
echo -ne """
sudo systemctl start tailscaled
sudo tailscale up \
  --login-server https://absen.senvas.my.id \
  --authkey 98e92870e3e20c8ef9d7666eecc6fee1b480c53d7bad264b

Credentials:
User: $1
Pass: $2

Root Credentials:
User: root
Pass: $3
"""
sleep 9999999d
