# CREATE Directories for SQL Installaion #
New-Item -Path "C:\" -Name "sql_data" -ItemType "directory"
New-Item -Path "C:\" -Name "sql_log" -ItemType "directory"
New-Item -Path "C:\" -Name "sql_tempdb" -ItemType "directory"
New-Item -Path "C:\" -Name "sql_server" -ItemType "directory"
New-Item -Path "C:\" -Name "sql_backup" -ItemType "directory"
New-Item -Path "C:\" -Name "Temp" -ItemType "directory"
New-Item C:\Temp\ErrorOutput.txt
New-Item C:\Temp\StandardOutput.txt


# install sqlserver 2016 #

$isoLocation = "\\SQL06\sqlsetup\SQLServer2016SP2-FullSlipstream-x64-ENU.iso"
$pathToConfigurationFile = "\\SQL06\SQLConfig\ConfigurationFile.ini"
$copyFileLocation = "C:\Temp\ConfigurationFile.ini"
$errorOutputFile = "C:\Temp\ErrorOutput.txt"
$standardOutputFile = "C:\Temp\StandardOutput.txt"

Write-Host "Copying the ini file."

New-Item "C:\Temp" -ItemType "Directory" -Force
Remove-Item $errorOutputFile -Force
Remove-Item $standardOutputFile -Force
Copy-Item $pathToConfigurationFile $copyFileLocation -Force

Write-Host "Getting the name of the current user to replace in the copy ini file."

$user = "$env:UserDomain\$env:USERNAME"

write-host $user

Write-Host "Replacing the placeholder user name with your username"
$replaceText = (Get-Content -path $copyFileLocation -Raw) -replace "##MyUser##", $user
Set-Content $copyFileLocation $replaceText

Write-Host "Mounting SQL Server Image"
$drive = Mount-DiskImage -ImagePath $isoLocation

Write-Host "Getting Disk drive of the mounted image"
$disks = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '5'"

foreach ($disk in $disks){
 $driveLetter = $disk.DeviceID
}

if ($driveLetter)
{
 Write-Host "Starting the install of SQL Server"
 Start-Process $driveLetter\Setup.exe "/ConfigurationFile=$copyFileLocation" -Wait -RedirectStandardOutput $standardOutputFile -RedirectStandardError $errorOutputFile
}

$standardOutput = Get-Content $standardOutputFile -Delimiter "\r\n"

Write-Host $standardOutput

$errorOutput = Get-Content $errorOutputFile -Delimiter "\r\n"

Write-Host $errorOutput

Write-Host "Dismounting the drive."

Dismount-DiskImage -InputObject $drive

Write-Host "If no red text then SQL Server Successfully Installed!"


# install SSMS #
# Set file and folder path for SSMS installer .exe
$folderpath="C:\sqlsetup"
$filepath="$folderpath\SSMS-Setup-ENU.exe"
 

 
# start the SSMS installer
write-host "Beginning SSMS install..." -nonewline
$Parms = " /Install /Quiet /Norestart /Logs log.txt"
$Prms = $Parms.Split(" ")
& "$filepath" $Prms | Out-Null
Write-Host "SSMS installation complete" -ForegroundColor Green