New-Item -ItemType Directory -Force -Path temp
New-Item -ItemType File -Force -Path temp/control-ip
New-Item -ItemType File -Force -Path temp/node-token
vagrant up
if (Test-Path ~/.ssh/known_hosts) {Remove-Item ~/.ssh/known_hosts}
$control_ip=$(Get-Content -path temp/control-ip)
scp -i .\vagrant_rsa vagrant@${control_ip}:/etc/rancher/k3s/k3s.yaml ./config
 (Get-Content -path ./config -Raw) -replace '127.0.0.1',"${control_ip}" | Out-File -Encoding "ascii" ./external_config