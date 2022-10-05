$data_ref = @();

foreach($line in Get-Content -Encoding UTF8 ".\reference.txt") {
        $data_ref += ,@(-split $line);
}

for($i=0; $i -lt $data_ref.Length; $i++) {
    for($j=0; $j -lt 2; $j++) {
        Write-Host $data_ref[$i][$j];
    }
}