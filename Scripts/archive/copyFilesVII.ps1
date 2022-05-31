

#\\192.168.131.10\Velocity II Migration Data\Final Migration files 8-5-2020\Electronic Statements May 2020\VII Statements_May2020

#\\ftp-srv\FTP-Data\Papasavvas\VII Statements


foreach($line in Get-Content "\\192.168.131.10\b2kcy\IT\Archive\Mass Allocation\papasavvas_VII statements.txt") {
   write-host $line

   $pdfFile = "\\192.168.131.10\Velocity II Migration Data\Final Migration files 8-5-2020\Electronic Statements May 2020\VII Statements_May2020\" + $line + ".pdf"
   Copy-Item  $pdfFile -Destination "\\ftp-srv\FTP-Data\Papasavvas\VII Statements\2020"

}


