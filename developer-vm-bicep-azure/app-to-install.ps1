if (!(Test-Path -Path C:\temp )) {
  New-Item -ItemType directory -Path C:\temp
}

Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
         
$installTime = Measure-Command {
  # install chocoloty
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
  # install notepade++
  choco install notepadplusplus.install --version=8.1.3 -y;
  # install vscode
  choco install vscode -y;
  # install apache
  choco install apache-httpd -y;
  # install chrome 
  choco install googlechrome --ignore-checksums -y 
}
$installTime.TotalMinutes | Out-File -FilePath C:\temp\install_time_total_min.txt