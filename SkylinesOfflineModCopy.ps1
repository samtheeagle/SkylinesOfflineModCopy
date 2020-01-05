##
## Powershell script to copy steam workshop items to the local appdata folder so that they are available in offline mode
##
## https://skylines.paradoxwikis.com/CRAP_File_Format
##

# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Set-ExecutionPolicy Restricted -Scope CurrentUser

# $env:PROCESSOR_ARCHITECTURE
# HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam

Set-Variable Is64Bit -value ($env:PROCESSOR_ARCHITECTURE -eq "AMD64")
Set-Variable SteamRegistryKey -value ("HKLM:\SOFTWARE\Valve\Steam", "HKLM:\SOFTWARE\Wow6432Node\Valve\Steam")[$Is64Bit -eq "True"]
Set-Variable SteamInstallFolder -value (Get-ItemPropertyValue -Path $SteamRegistryKey -Name InstallPath)
Set-Variable WorkshopContentFolder -value "$SteamInstallFolder\steamapps\workshop\content\255710"
Set-Variable LocalUserAddonsFolder -value "$env:LOCALAPPDATA\Colossal Order\Cities_Skylines\Addons"

Get-ChildItem -Path $WorkshopContentFolder -Directory | ForEach-Object {
    Set-Variable ModDll -value (Get-ChildItem -Path $_.FullName -Filter *.dll | Select-Object -First 1)
    Set-Variable IsMod -value ($ModDll.Length -gt 0)
    Set-Variable CurrentModFolder -value $_
    If ($IsMod) {
        Set-Variable LocalModPath -value ($LocalUserAddonsFolder+"\Mods\"+[System.IO.Path]::GetFileNameWithoutExtension($ModDll))
        New-Item -ItemType Directory -Force -Path $LocalModPath
        Get-ChildItem -Path $CurrentModFolder.FullName | Copy-Item -Destination $LocalModPath -Recurse -Container
    } Else {
        Get-ChildItem -Path $CurrentModFolder.FullName -Recurse | Copy-Item -Destination $LocalUserAddonsFolder\Assets
    }
}