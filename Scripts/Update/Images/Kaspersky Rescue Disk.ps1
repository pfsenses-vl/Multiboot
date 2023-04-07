$ErrorActionPreference = "SilentlyContinue"
$USB=Get-Disk -UniqueId "*USB*" | Get-Partition | Get-Volume
$USB=$USB.DriveLetter
$USB=$USB+":"
if (!(Test-Path "$USB\boot\Images\SharedImages")){New-Item -Path "$USB\boot\Images\SharedImages" -ItemType Directory | Out-Null}
$USB="$USB\boot\Images\SharedImages"
Set-location -Path $USB

#Kaspersky Rescue Disk
if (!(Test-Path "$USB\Antivirus\KRD")){New-Item -Path "$USB\Antivirus\KRD" -ItemType Directory | Out-Null}
$path="$USB\Antivirus\KRD\"
$name="KRD.iso"
Remove-Item $path\data -recurse -Force
Remove-Item $path\boot -recurse -Force
$url="https://rescuedisk.s.kaspersky-labs.com/latest/krd.iso"
$LocalMT=(Get-Item "$path$name")
$RemoteMT=Invoke-WebRequest $url -Method Head
if ((($LocalMT).LastwriteTime) -lt (($RemoteMT).Headers.'last-modified'))
{Start-BitsTransfer -Source $url -Destination $path$name
write-host "Kaspersky Rescue Disk was updated"}
else {
write-host "Kaspersky Rescue Disc aleady have latest version "
}
Start-Sleep 5
$ISODrive = (Get-DiskImage -ImagePath $path$name | Get-Volume).DriveLetter
IF (!$ISODrive) {
Mount-DiskImage -ImagePath $path$name -StorageType ISO > $null
}
$ISODrive = (Get-DiskImage -ImagePath $path$name | Get-Volume).DriveLetter
$ImagePath=$ISODrive+":"+"\"
Start-Sleep 2
New-Item -Path "$path\boot\grub" -ItemType Directory > $null
Copy-Item -Path "$ImagePath\boot\grub\initrd.xz" -Destination $path\boot\grub -Recurse -Container
Copy-Item -Path "$ImagePath\boot\grub\k-x86" -Destination $path\boot\grub -Recurse -Container
Copy-Item -Path "$ImagePath\boot\grub\k-x86_64" -Destination $path\boot\grub -Recurse -Container
Copy-Item -Path "$ImagePath\data\" -Destination $path\ -Recurse -Container
Dismount-DiskImage -ImagePath $path$name > $null
$defrag="L:\boot\Images"
$path+$name | Out-File -append $defrag\defrag.txt
