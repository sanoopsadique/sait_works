#Start
import-module ActiveDirectory
$choice = 'y'

$departments = @{
    EXEC = '0'
    0 = '0'
    ITS  = '17'
    17 = '17'
}


#Input computername
$asset= Read-Host -Prompt "Enter the asset#"

#Input localadmin account
$admin= Read-Host -Prompt "Enter the local admin email"

#Input OU#
$dept= Read-Host -Prompt "Enter the department name"

$current_name = $env:computername
$new_name = $dept+$asset
$ou = $departments[$dept]
$ou_path = 'OU='+$ou+',OU=Staff,OU=PCs,DC=ACDM,DC=DS,DC=SAIT,DC=CA'
$Credential = Get-Credential itdroplets\saitmgr
#Confirm
Write-Output '________________________________________________________'`r`n'Computer will be renamed from '$current_name' to '$new_name`r`n$admin' will be added as local administrator'`r`n'Device will be added to OU# '$ou
Write-Output '________________________________________________________'
$choice= Read-Host -Prompt 'Do you want to continue? (y/n)[y]'
if(($choice -eq 'y') -or ($choice -eq 'Y') -or ($choice -eq '')) {
    
    # Adding computer to OU
    Get-ADComputer $current_name | Move-ADObject -TargetPath $ou_path -Verbose

    # Adding user to the local admin group
    $user = Get-AdUser -Filter {emailaddress -eq $admin} -Credential $Credential
    if(!$user) { 
        Write-Output 'Error: User not found in active directory'
    }
    else {
        Add-LocalGroupMember -Group "Administrators" -Member $user.SamAccountName -Verbose
    }
    
    #Renaming computer
    Rename-Computer $new_name -Force -Verbose -DomainCredential $Credential

    #Restart
    $choice= Read-Host -Prompt "Do you want to restart now? (y/n)[y]"
    if(($choice -eq 'y') -or ($choice -eq 'Y') -or ($choice -eq '')) {
        Restart-Computer -Force
    }
    else {
        Write-Output 'Exiting script. Restart later to apply changes'
    }

}
else {
    Write-Output 'Cancelled and exiting'
}


