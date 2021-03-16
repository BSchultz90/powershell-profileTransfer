<#This is a Script to Copy Data from an Old Target PC to a New Target PC Over the Network  by Brice Schultz
Directories Copied  
C:\Users\ExampleUser\Desktop
C:\Users\ExampleUser\Favorites 
C:\Users\ExampleUser\Downloads
AppData: Chrome Bookmarks | Sticky Notes | Signatures | OneNote | MS Templates#>

#TODO: No Todos for Once! Wooohooo!

Write-Host "`n --- Profile-Transfer
 |  By Brice Schultz --- `n" -ForegroundColor Green

#Globally Scoped PowerShell Variables
$ErrorActionPreference = "SilentlyContinue"

#The Variables Below pass the input to the Pathnames listed above, Establish PSSessions with the Old and New PCs and Pull in Values for Later Use.
$OldPC = Read-Host -Prompt ' Enter The Old PC Name Here'
$NewPC = Read-Host -Prompt ' Enter The New PC Name Here'
$Username = Read-Host -Prompt ' Enter Target User Profile Here'

#Establishes Persistent PS Sessions With the Old and New PC
$OldPC_Session = New-PSSession -ComputerName $OldPC
$NewPC_Session = New-PSSession -ComputerName $NewPC


Write-Host "`n Warning: If both Machines are on Wireless the Tool will not work due to P2P blocking | Also Ensure that Profile and PC names are Correct" -ForegroundColor Yellow

New-Item -Path "\\$NewPC\c$\" -Name "Profile-Transfer
" -ItemType "Directory"

#These Lines will Export all the Printer Connections to a Registry Key | Copy it to the New PC and Import Back into the Registry
Invoke-Command -Session $OldPC_Session -ScriptBlock {REG EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Connections" C:\Printer_Connections.reg /y}
Copy-Item -Path "\\$OldPC\c$\Printer_Connections.reg" -Destination "\\$NewPC\c$\Profile-Transfer
" -Recurse
Invoke-Command -Session $NewPC_Session -ScriptBlock {REG IMPORT "C:\Profile-Transfer
\Printer_Connections.reg"}

#The Code Below Copies all of the Major Directories from the Old PC to the New PC
Write-Host "`n -------------  Data Transfer In Progress   -------------" -ForegroundColor Green

Copy-Item -Path "\\$OldPc\c$\Users\$Username\Desktop" -Destination "\\$NewPC\c$\Profile-Transfer
\" -Recurse
Copy-Item -Path "\\$OldPc\c$\Users\$Username\Downloads" -Destination "\\$NewPC\c$\Profile-Transfer
\" -Recurse
Copy-Item -Path "\\$OldPc\c$\Users\$Username\Favorites" -Destination "\\$NewPC\c$\Profile-Transfer
\" -Recurse
Copy-Item -Path "\\$OldPc\c$\Users\$Username\AppData\Roaming\Microsoft\Signatures\" -Destination "\\$NewPC\c$\Profile-Transfer
\" -Recurse
Copy-Item -Path "\\$OldPc\c$\Users\$Username\AppData\Roaming\Microsoft\OneNote" -Destination "\\$NewPC\c$\Profile-Transfer
\" -Recurse
Copy-Item -Path "\\$OldPc\c$\Users\$Username\AppData\Roaming\Microsoft\Sticky Notes" -Destination "\\$NewPC\c$\Profile-Transfer
\" -Recurse

#Chrome Bookmarks Require Chrome to be Launched for them to Import Over with the Move Files Script 
Copy-Item -Path "\\$OldPc\c$\Users\$Username\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" -Destination "\\$NewPC\c$\Profile-Transfer
" -Recurse
Copy-Item -Path "\\PHX00134\Support\Desktop\ITPT\Scripts\Profile-Transfer
 Code\Move Files.lnk" -Destination "\\$NewPC\c$\Users\Public\Desktop"

#This Copies the Code Dependencies Host from the Specificed Directory. (Move Files Script / Map Drives.bat etc)
Copy-Item -Path "*Pathto\Profile-Transfer
 Code\" -Destination "\\$NewPC\c$\Profile-Transfer
" -Recurse

Write-Host "`n `n -------------  Data Transfer Complete   -------------" -ForegroundColor Green

#Logs the PC to a Text File on 134
$Timestamp = Get-Date
Add-Content -Path "*PathToLog\log.txt" -Value "Old PC: $OldPC  |   New PC: $NewPC  |  Timestamp: $Timestamp  |  Tech: $env:USERNAME "

<#
Depricating Out the Following Features | Scheduled Task Automation as the Task cannot be torn down properly anymore & Automatic Emailing as per Microsofts Docs on Send-MailMessage it is not as secure as once thought.

#The Following Lines Create a Scheduled Task on the New PC to Move the Data after the User Logs in | After the Data is moved the Scheduled Task is Torn down by the Move Files Script.
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\Profile-Transfer
\Profile-Transfer
 Code\Refresh_Transfer_MoveFiles.ps1" -Windowstyle Hidden'
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User "Domain\$Username"
Invoke-Command -ComputerName $NewPC -ScriptBlock {Register-ScheduledTask -TaskName 'Move Files' -User $Using:Username -Action $Using:Action -Trigger $Using:Trigger -Description "Runs the Move Files Script to Complete a Profile-Transfer
"}
