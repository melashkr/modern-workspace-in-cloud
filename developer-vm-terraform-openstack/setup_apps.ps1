
#Check if 'temp' folder exists, if not create one
# if (!(Test-Path -Path C:\temp )) {
#     New-Item -ItemType directory -Path C:\temp
# }

# Set-ExecutionPolicy Bypass -Scope Process -Force;
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;

# $installTime = Measure-Command {
    
#     iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    
#     choco install googlechrome -y
# } 

#| Out-File C:\install_time.txt

# $installTime.TotalMinutes | Out-File -FilePath C:\Users\adminstrator\install_time_total_min.txt