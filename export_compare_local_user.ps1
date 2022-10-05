#export local users in a .csv file
#compare this .csv with an older one
#if the list has changed (added or deleted account)
#write an event

#this code is part of a Windows AD project


#check is Source exist
if ([System.Diagnostics.EventLog]::SourceExists('SecurityCenter')) {
    continue;
}
else {
    New-EventLog -LogName Application -Source "SecurityCenter";
}

if (Test-Path -Path "$env:windir\reference.csv") {
    #export local users
    Get-LocalUser | Select-Object -Property Name | Export-Csv -Encoding UTF8 -NoTypeInformation "$env:windir\tmp.csv";


    #retrieving the two .csv files for comparing them
    $CSV_REF = Import-Csv "$env:windir\reference.csv" -Delimiter ",";
    $CSV_TMP = Import-Csv "$env:windir\tmp.csv" -Delimiter ",";

    $compare = Compare-Object -ReferenceObject $CSV_REF -DifferenceObject $CSV_TMP -Property Name;

    if($compare.Length -eq 0) {
        Remove-Item "$env:windir\tmp.csv"; 
    }
    else {        
        #Application log writing
        for($i=0; $i -lt $compare.Length; $i++)
        {
            if($compare[$i].SideIndicator -eq "=>") {
                Write-EventLog -LogName Application -Source "SecurityCenter" -EventID 4720 -EntryType Information -Message "An user account has been created." -Category 0 -RawData 10,20;
            }
            else {
                Write-EventLog -LogName Application -Source "SecurityCenter" -EventID 4726 -EntryType Information -Message "An user account has been deleted." -Category 0 -RawData 10,20;
            }
        }

        #delete the tmp file, update the reference file
        $CSV_TMP | Export-Csv -Encoding UTF8 -NoTypeInformation "$env:windir\reference.csv";
        Remove-Item "$env:windir\tmp.csv";
    }    
}

else {
    #first launch or no file, create the local users .csv file
    Get-LocalUser | Select-Object -Property Name | Export-Csv -Encoding UTF8 -NoTypeInformation "$env:windir\reference.csv";
}