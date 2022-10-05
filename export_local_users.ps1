#export local users and their status (enabled, disabled)
Get-LocalUser | Select-Object -Property Name,Enabled | Export-Csv -Encoding UTF8 -NoTypeInformation ".\users.csv";