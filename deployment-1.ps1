#Start
import-module ActiveDirectory
$choice = 'y'
#Input computername
$name= Read-Host -Prompt "Enter the computer name"

#Input localadmin account
$admin= Read-Host -Prompt "Enter the local admin email"

#Input OU#
$ou= Read-Host -Prompt "Enter the department code"

#Confirm
Write-Output '-------------------------------------------------------'`r`n'Computer will be renamed to '$name`r`n$admin' will be added as admin'`r`n'Device will be added to OU# '$ou'.'
$choice= Read-Host -Prompt 'Do you want to continue? (y/n)[y]'
if ($choice -eq 'y') {
    #Renaming computer
    Rename-Computer $name -Force -Verbose
    # Adding user to the local admin group
    $sam = ($admin -split "@")[0]
    $t = Get-AdUser -F {SamAccountName -eq $sam}
    if(!$t) { 
        Write-Output 'Error: User not found in active directory'
    }
    else {
        Add-LocalGroupMember -Group "Administrators" -Member $sam -Verbose
    }
    # Adding computer to OU
    Get-ADComputer $name | Move-ADObject -TargetPath 'OU='$ou',OU=Staff,OU=PCs,DC=ACDM,DC=DS,DC=SAIT,DC=CA' -Verbose

    #Restart
    $choice= Read-Host -Prompt "Do you want to restart? (y/n)[y]"
    if($choice -eq 'y') {
        Restart-Computer -Force
    }

}


