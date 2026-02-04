# LinuxGUI
https://hub.docker.com/r/ductris/linuxgui
## Version
* 1.0
## Feature
- XRDP ( Audio, h.264 Enc Support), port 3389
- Xfce4 Desktop Env
## RUN
```bash
docker run --name linuxguiii -p 0.0.0.0:3389:3389 -it ductris/linuxgui:latest
```
### RUN Again ( The old data is still saved )
```bash
docker start linuxguiii
```
## CONNECT
### User Credentials
after run then go port 3389 (RDP),default credentials is

User: `linux`

Pass: `linuxgui`
### Admin ( root ) Default Credentials

User: `root`
Pass: `linuxgui`


