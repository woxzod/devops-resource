cd /opt
sudo mkdir alertmanager
sudo chown $USER:$USER alertmanager
cd alertmanager

LATEST=$(curl -s https://api.github.com/repos/prometheus/alertmanager/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4)

wget $LATEST
tar -xzf alertmanager-*.tar.gz
mv alertmanager-*/alertmanager .
mv alertmanager-*/amtool .
mv alertmanager-*/alertmanager.yml .
rm -rf alertmanager-*
