
$path = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\RawData\"
$archive = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\RawData\archive"
$outputFolder = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\SeparatedFiles\" #"\\B2K-TEST\LDEroot\LdeFiles\B2KCY228\separatefiles"
Get-ChildItem -Path $path\*.txt  -Force|

Foreach-Object {
#$_.BaseName


    $CharArray =$_.BaseName.Split("-")
    $String1= $CharArray[0]

    $fileDate = $String1.Replace("CYBOC_B2K_RECONCILIATION_","")

    $headerFile = $outputFolder + "\B2K_Header_" + $fileDate + ".txt"
    $detailsFile = $outputFolder + "\B2K_Details_" + $fileDate + ".txt"

    if (Test-Path $headerFile)  { Remove-Item $headerFile }
    if (Test-Path $detailsFile) { Remove-Item $detailsFile }

    $lineNo = 0;

    foreach($line in [System.IO.File]::ReadLines($_.FullName))
    {
        if($lineNo -eq 0){
            write-output $line | out-file -append -encoding unicode $headerFile  -Force 
            $lineNo = 1;
        }
        else
        {
            write-output $line | out-file -append  -encoding unicode $detailsFile -Force 
        }
    }
    
}


Get-ChildItem -Path $path\*.txt  -Force| Move-Item -Destination  $archive -Force 







