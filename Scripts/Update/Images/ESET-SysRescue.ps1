##################################
#Update script for Eset Sysrescue
##################################
$ErrorActionPreference = "SilentlyContinue"
$USB=Get-Disk -UniqueId "*USB*" | Get-Partition | Get-Volume
$USB=$USB.DriveLetter
$USB=$USB+":"
if (!(Test-Path "$USB\boot\Images\SharedImages")){New-Item -Path "$USB\boot\Images\SharedImages" -ItemType Directory | Out-Null}
$USB="$USB\boot\Images\SharedImages"
Set-location -Path $USB

#Eset System Rescue
if (!(Test-Path "$USB\Antivirus\ESET")){New-Item -Path "$USB\Antivirus\ESET" -ItemType Directory | Out-Null}
$url="https://download.eset.com/com/eset/tools/recovery/rescue_cd/latest/eset_sysrescue_live_enu.iso"
$path="$USB\Antivirus\ESET\"
$name="ESET.iso"
$casper="casper"
Remove-Item $path\$casper\vmlinuz -Force
Remove-Item $path\$casper\initrd.lz -Force
Remove-Item $path\$casper\filesystem.squashfs -Force
$LocalMT=(Get-Item "$path$name")
$RemoteMT=Invoke-WebRequest $url -Method Head
if ((($LocalMT).LastwriteTime) -lt (($RemoteMT).Headers.'last-modified'))
{Start-BitsTransfer -Source $url -Destination $path$name
write-host "Eset SysRescue was updated"}
else {
write-host "Eset SysRescue aleady have latest version "
}
$ISODrive = (Get-DiskImage -ImagePath $path$name | Get-Volume).DriveLetter
IF (!$ISODrive) {
Mount-DiskImage -ImagePath $path$name -StorageType ISO > $null
}
$ISODrive = (Get-DiskImage -ImagePath $path$name | Get-Volume).DriveLetter
$ImagePath=$ISODrive+":"+"\"
Start-Sleep 5
New-Item -Path "$path\casper" -ItemType Directory
Copy-Item -Path $ImagePath\casper\vmlinuz -Destination $path\$casper\
Copy-Item -Path $ImagePath\casper\initrd.lz -Destination $path\$casper\
Copy-Item -Path $ImagePath\casper\filesystem.squashfs -Destination $path\$casper\
Dismount-DiskImage -ImagePath $path$name > $null
$defrag="L:\boot\Images"
$path+$name | Out-File -append $defrag\defrag.txt
