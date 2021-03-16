<# This is Part Two to the Data Transfer Script, this Script will move all files from The Created Refresh Transfer Directory to the Proper Directories#>

#TODO: Default Printer set to MySecurePrint 

$ErrorActionPreference = "SilentlyContinue"

$User = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Username
$Username = $User -replace 'BHS\\',""
$PathTest = Test-Path -Path "C:\Users\$Username"

if($null -eq $PathTest){
    Write-Host "User Directory for $Username is not Present! Please Double Check that you are logged into the Target User Profile." -ForegroundColor 'Red'
} else {
    Get-ChildItem -Path "C:\Refresh Transfer\Desktop" -Exclude *.lnk -Recurse | Move-Item -Destination "C:\Users\$Username\Desktop" -Force
    Get-ChildItem -Path "C:\Refresh Transfer\Favorites" -Recurse | Move-Item -Destination "C:\Users\$Username\Favorites" -Force 
    Get-ChildItem -Path "C:\Refresh Transfer\Downloads" -Recurse | Move-Item -Destination "C:\Users\$Username\Downloads" -Force
    Get-ChildItem -Path "C:\Refresh Transfer\OneNote" -Recurse | Move-Item -Destination "C:\Users\$Username\AppData\Roaming\Microsoft\OneNote" -Force
    #AppData Stuff that For some reason hates me and forces me to Use Copy-Item 
    Copy-Item -Path "C:\Refresh Transfer\Signatures" -Destination "C:\Users\$Username\AppData\Roaming\Microsoft\" -Recurse  
    Copy-Item -Path "C:\Refresh Transfer\Sticky Notes"  -Destination "C:\Users\$Username\AppData\Roaming\Microsoft\"  -Recurse 
    Copy-Item -Path "C:\Refresh Transfer\Bookmarks" -Destination "\\$NewPC\c$\Users\$Username\AppData\Local\Google\Chrome\User Data\Default\" -Recurse

    Remove-Item -Path "C:\Users\Public\Desktop\Move Files.lnk"
    Remove-Item -Path "C:\Refresh Transfer" -Recurse -Force

    Exit
}
