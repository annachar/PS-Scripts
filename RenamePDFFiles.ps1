$source = "C:\Users\ach\Desktop\SML2 Letters\RegisteredDebtors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "RegisteredDebtorsSML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\RegisteredDebtor_$($_.newfilename).pdf" }

