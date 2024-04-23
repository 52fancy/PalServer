#!sh
apt -y install lib32gcc1 libc6-i386
STEAMROOT="${XDG_DATA_HOME:-"$HOME"}/.steam"
mkdir -p $STEAMROOT
cd $STEAMROOT
wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf -
./steamcmd.sh +quit
ln -s $STEAMROOT/linux32 $STEAMROOT/sdk32
ln -s $STEAMROOT/linux64 $STEAMROOT/sdk64
ln -s $STEAMROOT/linux32/steamclient.so $STEAMROOT/linux32/steamservice.so
ln -s $STEAMROOT/linux64/steamclient.so $STEAMROOT/linux64/steamservice.so
./steamcmd.sh +login anonymous +app_update 1007 +quit
./steamcmd.sh +login anonymous +app_update 2394010 validate +quit

cat <<EOF > /usr/lib/systemd/system/PalServer.service
[Unit]
Description=PalServer.service
Wants=network-online.target
After=network.target network-online.target

[Service]
User=steam
Restart=on-failure
ExecStart=$HOME/Steam/steamapps/common/PalServer/PalServer.sh -publiclobby -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS

[Install]
WantedBy=multi-user.target
EOF

useradd -g 0 -s /usr/sbin/nologin steam
chmod -R g+rx $HOME
chown -R steam:root $HOME/Steam

systemctl daemon-reload
systemctl enable PalServer
systemctl start PalServer
