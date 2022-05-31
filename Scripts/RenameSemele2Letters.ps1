$source = "C:\Users\ach\Desktop\SML2 Letters\RegisteredDebtors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "RegisteredDebtorsSML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\RegisteredDebtor_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Registered Deceased Debtors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Registered Deceased DebtorsSML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\RegisteredDeceasedDebtor_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Registered Deceased Guarantors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Registered Deceased Guarantors SML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\RegisteredDeceasedGuarantor_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Registered Guarantors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Registered Guarantors SML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\RegisteredGuarantor_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Deceased Guarantors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Deceased GuarantorsSML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\Deceased Guarantor_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Deceased-Guarantors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Deceased-GuarantorsSML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\Deceased-Guarantor_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Deceased-Debtors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Deceased-DebtorsSML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\Deceased-Debtor_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Batch 2_Debtors1"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Batch 2_Debtors1SML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\Batch 2_Debtors1_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Debtors"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "DebtorsSML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\Debtor_$($_.newfilename).pdf" }


$source = "C:\Users\ach\Desktop\SML2 Letters\Guarantors1"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Guarantors1SML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\Guarantors1_$($_.newfilename).pdf" }

$source = "C:\Users\ach\Desktop\SML2 Letters\Guarantors2"
$target = "C:\Users\ach\Desktop\SML2 Letters\" + "Guarantors2SML2"
Import-Csv "$source\DataExtract.csv" | % { Copy-Item -Path "$source\$($_.oldfilepath)"   -Destination "$target\Guarantors2_$($_.newfilename).pdf" }
