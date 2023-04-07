##################################
#Update script for Dr-Web LiveDisk
##################################
$ErrorActionPreference = "SilentlyContinue"
$USB=Get-Disk -UniqueId "*USB*" | Get-Partition | Get-Volume
$USB=$USB.DriveLetter
$USB=$USB+":"
if (!(Test-Path "$USB\boot\Images\SharedImages")){New-Item -Path "$USB\boot\Images\SharedImages" -ItemType Directory | Out-Null}
$USB="$USB\boot\Images\SharedImages"
Set-location -Path $USB

#DR.Web LiveDisk
if (!(Test-Path "$USB\Antivirus\DRWEB")){New-Item -Path "$USB\Antivirus\DRWEB" -ItemType Directory | Out-Null}
$url="https://download.geo.drweb.com/pub/drweb/livedisk/drweb-livedisk-900-cd.iso"
$path="$USB\Antivirus\DRWEB\"
$name="DRWEB.iso"
$casper="casper"
Remove-Item $path\$casper\vmlinuz -Force
Remove-Item $path\$casper\initrd.lz -Force
Remove-Item $path\$casper\0filesystem.squashfs -Force
Remove-Item $path\$casper\drweb-10bin.squashfs -Force
Remove-Item $path\$casper\drweb-25key.squashfs -Force
Remove-Item $path\$casper\drweb-50bases.squashfs -Force
$LocalMT=(Get-Item "$path$name")
$RemoteMT=Invoke-WebRequest $url -Method Head
if ((($LocalMT).LastwriteTime) -lt (($RemoteMT).Headers.'last-modified'))
{Start-BitsTransfer -Source $url -Destination $path$name
write-host "Dr. Web was updated"}
else {
write-host "Dr. Web aleady have latest version "
}
$ISODrive = (Get-DiskImage -ImagePath $path$name | Get-Volume).DriveLetter
IF (!$ISODrive) {
Mount-DiskImage -ImagePath $path$name -StorageType ISO > $null
}
$ISODrive = (Get-DiskImage -ImagePath $path$name | Get-Volume).DriveLetter
$ImagePath=$ISODrive+":"+"\"+"casper"
Start-Sleep 5
New-Item -Path "$path\casper" -ItemType Directory > $null
Copy-Item -Path $ImagePath\vmlinuz -Destination $path\$casper
Copy-Item -Path $ImagePath\initrd.lz -Destination $path\$casper
Copy-Item -Path $ImagePath\0filesystem.squashfs -Destination $path\$casper
Copy-Item -Path $ImagePath\drweb-10bin.squashfs -Destination $path\$casper
Copy-Item -Path $ImagePath\drweb-25key.squashfs -Destination $path\$casper
Copy-Item -Path $ImagePath\drweb-50bases.squashfs -Destination $path\$casper
Dismount-DiskImage -ImagePath $path$name > $null
$defrag="L:\boot\Images"
$path+$name | Out-File -append $defrag\defrag.txt
