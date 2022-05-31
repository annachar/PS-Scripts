param([string]$currentDir,[string]$filename)

$path = $currentDir
$month = get-date -format MM
$year = get-date -format yyyy
$monthName = (Get-Culture).DateTimeFormat.GetMonthName($month)


if([string]::IsNullOrWhitespace($path))
{
   $path="\\192.168.131.10\b2kcy\IT\!Pending\HBfiles\"
}

$XMLPath = "$path\MultiplePaymentsHellenicSML2" + $monthName + $year + ".xml"
$excelPath = $filename #"$path\" + $filename + ".xls"

write-host $excelPath
#Write-Host "Initializing new XML document" 
[xml]$Doc = New-Object System.Xml.XmlDocument
 
$dec = $Doc.CreateXmlDeclaration("1.0","ISO-8859-1",$null)
$doc.AppendChild($dec) | Out-Null

######################### start excel configuration #########################
#$lastCell = 3 
$startRow = 2
$Nm=1
$PmtInfId= 2
$SvcLvlCd=3
$CtgyPurpCd=4
$ReqdExctnDt = 5
$ChrgBr = 6
$ChrgBrAccountNo = 7
$EndToEndId=8
$InstdAmt=9
$BIC=10
$BeneficiaryNm=11
$IBAN=12
$CreditorID=13
$Ustrd=14

$excel = New-Object -ComObject excel.application
$wb = $excel.workbooks.open($excelPath)
$sh = $wb.Sheets.Item(5)
$endRow = $sh.UsedRange.Rows.Count
######################### end excel configuration ###########################

#Write-host "Total number of rows: $endRow" -ForegroundColor Green

#create root Node
$root = $doc.CreateNode("element","Document",$null)
$root.SetAttribute("xmlns", "urn:iso:std:iso:20022:tech:xsd:pain.001.001.03")
$root.SetAttribute("xmlns:NS1", "http://www.w3.org/2001/XMLSchema-instance")

######################### start group header #########################
$CstmrCdtTrfInitn = $doc.CreateNode("element","CstmrCdtTrfInitn",$null) 
$c = $doc.CreateNode("element","GrpHdr",$null) 

$e = $doc.CreateElement("MsgId") #Οποιοδήποτε αριθμός αναφοράς μπορεί να δοθεί ως όνομα του αρχείου
$e.InnerText = "payments for $month"   
$c.AppendChild($e) | Out-Null 

$e = $doc.CreateElement("CreDtTm") #Creation date and time of the file.Example: 2012-02-03T11:20:45
$e.InnerText = get-date -format s
$c.AppendChild($e) | Out-Null

$e = $doc.CreateElement("NbOfTxs") #The number of transactions within the file.
$e.InnerText = $endRow-1
$c.AppendChild($e) | Out-Null

#########################
$e = $doc.CreateElement("CtrlSum") #Το συνολικό ποσό των πιστώσεων πχ αν πιστώνονται 3 δικαιούχοι προς 100 ευρώ το ποσό που θα αναγραφεί είναι 300.00
$total = 0
for ($i=$startRow; $i -le $endRow; $i++)
{
    $total = $total + $sh.Cells.Item($startRow,$InstdAmt).Value2
    $startRow++
}
$startRow = 2
$e.InnerText =  $total
$c.AppendChild($e) | Out-Null
#########################


$e = $doc.CreateElement("InitgPty") 
$e1 = $doc.CreateElement("Nm") #Name of the ordering party.
$e1.InnerText = "B2Kapital Cyprus Ltd"
$e.AppendChild($e1) | Out-Null

#$c1 = $doc.CreateNode("element","Id",$null) #Name of the ordering party.
#$c2 = $doc.CreateNode("element","OrgId",$null) #Name of the ordering party.
#$c3 = $doc.CreateNode("element","Othr",$null) #Name of the ordering party.
#$c4 = $doc.CreateElement("Id") #Name of the ordering party.
#$c4.InnerText = "B2Kapital Cyprus Ltd"

#$c3.AppendChild($c4) | Out-Null
#$c2.AppendChild($c3) | Out-Null
#$c1.AppendChild($c2) | Out-Null

#$e.AppendChild($c1) | Out-Null


$c.AppendChild($e) | Out-Null

$CstmrCdtTrfInitn.AppendChild($c) | Out-Null

######################### end of group header #########################



######################### start create payment info row #########################
$paymentRowInfo = for ($i=$startRow; $i -le $endRow; $i++)
{
    $c = $doc.CreateNode("element","PmtInf",$null) 

    ### LEVEL 1 ##################################################################################################################################################################################
    $e = $doc.CreateElement("PmtInfId") #Unique reference number of each Transaction 
    $e.InnerText = $sh.Cells.Item($startRow,$PmtInfId).Value2
    $c.AppendChild($e) | Out-Null
    ##############################################################################################################################################################################################


    ### LEVEL 1 ##################################################################################################################################################################################
    $e = $doc.CreateElement("PmtMtd") #TRF (Fixed Value for credit transfers) is requested
    $e.InnerText = "TRF"
    $c.AppendChild($e) | Out-Null
    ##############################################################################################################################################################################################

     ### LEVEL 1 ##################################################################################################################################################################################
    $e = $doc.CreateElement("BtchBookg") #TRF (Fixed Value for credit transfers) is requested
    $e.InnerText = "1"
    $c.AppendChild($e) | Out-Null
    ##############################################################################################################################################################################################            

    ### LEVEL 1 ##################################################################################################################################################################################
    $c1 = $doc.CreateNode("element","PmtTpInf",$null)
    $c2 = $doc.CreateNode("element","SvcLvl",$null) 
    $e = $doc.CreateElement("Cd") #Τransaction Type based on Appendix B
    $e.InnerText = $sh.Cells.Item($startRow,$SvcLvlCd).Value2 
    $c2.AppendChild($e) | Out-Null
    $c1.AppendChild($c2) | Out-Null
    $c.AppendChild($c1) | Out-Null
    ##############################################################################################################################################################################################



    ### LEVEL 1 ##################################################################################################################################################################################
    $e = $doc.CreateElement("ReqdExctnDt") #Execution Date -This is the date on which the originator’s account is to be debited
    $e.InnerText = $sh.Cells.Item($startRow,$ReqdExctnDt).Value2
    $c.AppendChild($e) | Out-Null
    ##############################################################################################################################################################################################


                 
    ### LEVEL 1 ##################################################################################################################################################################################
    $c1 = $doc.CreateNode("element","Dbtr",$null) 
    ###
    $e = $doc.CreateElement("Nm") #Name of the originator
    $e.InnerText = "B2Kapital Cyprus Ltd"
    $c1.AppendChild($e) | Out-Null
    ###
    $c3 = $doc.CreateNode("element","PstlAdr",$null)
    $e = $doc.CreateElement("element","Ctry",$null)
    $e.InnerText = "CY"
    $c3.AppendChild($e) | Out-Null
    $c1.AppendChild($c3) | Out-Null
    $c.AppendChild($c1) | Out-Null
    ##############################################################################################################################################################################################

    $c3 = $doc.CreateNode("element","Id",$null)
    $c4 = $doc.CreateNode("element","OrgId",$null)
    $e = $doc.CreateElement("element","BICOrBEI",$null)
    $e.InnerText = "HEBACY2N"
    $c4.AppendChild($e) | Out-Null
    $c3.AppendChild($c4) | Out-Null
    $c1.AppendChild($c3) | Out-Null
    $c.AppendChild($c1) | Out-Null


                
    ### LEVEL 1 ##################################################################################################################################################################################
    $c1 = $doc.CreateNode("element","DbtrAcct",$null) 
    ###
    $c3 = $doc.CreateNode("element","Id",$null) 
    $e = $doc.CreateElement("element","IBAN",$null) #IBAN account number of originator
    $e.InnerText = "CY71005002150002150181969903"
    $e1 = $doc.CreateElement("element","Ccy",$null) #IBAN account number of originator
    $e1.InnerText = "EUR"
    $c3.AppendChild($e) | Out-Null
    $c1.AppendChild($c3) | Out-Null
    $c1.AppendChild($e1) | Out-Null
    $c.AppendChild($c1) | Out-Null
    ##############################################################################################################################################################################################


                
    ### LEVEL 1 ##################################################################################################################################################################################
    $c1 = $doc.CreateNode("element","DbtrAgt",$null) 
    ###
    $c2 = $doc.CreateNode("element","FinInstnId",$null) 
    $e = $doc.CreateElement("element","BIC",$null) #SWIFT BIC code of the remitting bank.
    $e.InnerText = $sh.Cells.Item($startRow,$BIC).Value2
    $c2.AppendChild($e) | Out-Null
    $c1.AppendChild($c2) | Out-Null
    $c.AppendChild($c1) | Out-Null
    ##############################################################################################################################################################################################

     ### LEVEL 1 ##################################################################################################################################################################################
    if(![string]::IsNullOrWhitespace($sh.Cells.Item($startRow,$ChrgBr).Value2))
    {

        ### LEVEL 1 ##################################################################################################################################################################################
        $e = $doc.CreateElement("ChrgBr") #Define who will bear charges
        $chargesBearer = $sh.Cells.Item($startRow,$ChrgBr).Value2
        $e.InnerText = $chargesBearer
        $c.AppendChild($e) | Out-Null
    }
    ##############################################################################################################################################################################################


    ### LEVEL 1 ##################################################################################################################################################################################
    $c1 = $doc.CreateNode("element","CdtTrfTxInf",$null)
    ###
    $c2 = $doc.CreateNode("element","PmtId",$null)
    $e = $doc.CreateElement("element","InstrId",$null)
    $e.InnerText = "InstrId" # $sh.Cells.Item($startRow,$InstrId).Value2
    $c2.AppendChild($e) | Out-Null
    ###
    $e = $doc.CreateElement("element","EndToEndId",$null)
    $e.InnerText = $sh.Cells.Item($startRow,$EndToEndId).Value2
    $c2.AppendChild($e) | Out-Null
    $c1.AppendChild($c2) | Out-Null
    ###
    $c2 = $doc.CreateNode("element","PmtTpInf",$null)
    $c3 = $doc.CreateNode("element","SvcLvl",$null)
    $e = $doc.CreateElement("element","Cd",$null)
    $e.InnerText =$sh.Cells.Item($startRow,$SvcLvlCd).Value2
    $c3.AppendChild($e) | Out-Null
    $c2.AppendChild($c3) | Out-Null
    $c3 = $doc.CreateNode("element","CtgyPurp",$null)
    $e = $doc.CreateElement("element","Cd",$null)
    $e.InnerText =  $sh.Cells.Item($startRow,$CtgyPurpCd).Value2
    $c3.AppendChild($e) | Out-Null
    $c2.AppendChild($c3) | Out-Null
    $c1.AppendChild($c2) | Out-Null
    ###
    $c2 = $doc.CreateNode("element","Amt",$null)
    $e = $doc.CreateElement("element","InstdAmt",$null)
    $e.SetAttribute("Ccy","EUR")
    $e.InnerText =   $sh.Cells.Item($startRow,$InstdAmt).Value2
    $c2.AppendChild($e) | Out-Null
    $c1.AppendChild($c2) | Out-Null
   
    ### LEVEL 1 ##################################################################################################################################################################################
    if(![string]::IsNullOrWhitespace($sh.Cells.Item($startRow,$ChrgBr).Value2))
    {

        ### LEVEL 1 ##################################################################################################################################################################################
        $e = $doc.CreateElement("ChrgBr") #Define who will bear charges
        $chargesBearer = $sh.Cells.Item($startRow,$ChrgBr).Value2
        $e.InnerText = $chargesBearer
        $c1.AppendChild($e) | Out-Null


        $c2 = $doc.CreateNode("element","CdtrAgt",$null)
        $c3 = $doc.CreateNode("element","FinInstnId",$null)
        $e = $doc.CreateElement("BIC") #Define who will bear charges
        $e.InnerText = $sh.Cells.Item($startRow,$ChrgBrAccountNo).Value2
        $c3.AppendChild($e) | Out-Null
        $c2.AppendChild($c3) | Out-Null
        $c1.AppendChild($c2) | Out-Null

    }
    ##############################################################################################################################################################################################


    ###
    $c2 = $doc.CreateNode("element","Cdtr",$null)
    $e = $doc.CreateElement("element","Nm",$null)
    $e.InnerText = $sh.Cells.Item($startRow,$BeneficiaryNm).Value2
    $c2.AppendChild($e) | Out-Null
    $c1.AppendChild($c2) | Out-Null
    ###
    $c2 = $doc.CreateNode("element","CdtrAcct",$null)
    $c3 = $doc.CreateNode("element","Id",$null)
    $e1 = $doc.CreateElement("element","IBAN",$null)
    $e1.InnerText = $sh.Cells.Item($startRow,$IBAN).Value2 #IBAN account number of creditor. Use capitals
    $c3.AppendChild($e1) | Out-Null
    $c2.AppendChild($c3) | Out-Null
    $c1.AppendChild($c2) | Out-Null
    ###
    #$c2 = $doc.CreateNode("element","RltdRmtInf",$null)
    #$e1 = $doc.CreateElement("element","RmtLctnElctrncAdr",$null) #The email entered will be used for sending updates of transactions status.
    #$e1.InnerText = "accounting@b2kapital.com.cy"
    #$c2.AppendChild($e1) | Out-Null
    #$c1.AppendChild($c2) | Out-Null
    ###
    $c2 = $doc.CreateNode("element","RmtInf",$null)
    $e1 = $doc.CreateElement("element","Ustrd",$null)#Remittance info / payment details (description)
    $e1.InnerText = $sh.Cells.Item($startRow,$Ustrd).Value2
    $c2.AppendChild($e1) | Out-Null
    $c1.AppendChild($c2) | Out-Null
    ##############################################################################################################################################################################################



    ##############################################################################################################################################################################################
    $c.AppendChild($c1) | Out-Null
    $CstmrCdtTrfInitn.AppendChild($c) | Out-Null
    ##############################################################################################################################################################################################

    $startRow++
}
# end create payment info row
$root.AppendChild($CstmrCdtTrfInitn) | Out-Null

#add root to the document
$doc.AppendChild($root) | Out-Null
 
#save file
#Write-Host "Saving the XML document to $XMLPath" -ForegroundColor Green
$doc.save($XMLPath)
 
Write-Host "XML generation completed succesfully" #-ForegroundColor green

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
Remove-Variable excel


##############################################################################################################################################################################################
######################################################################################## VALIDATE XML ########################################################################################
function Test-XmlFile
{
    [CmdletBinding()]
    param (     
        [Parameter(Mandatory=$true)]
        [string] $SchemaFile,

        [Parameter(ValueFromPipeline=$true, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [alias('Fullname')]
        [string] $XmlFile,

        [scriptblock] $ValidationEventHandler = { Write-Error $args[1].Exception }
    )

    begin {
        $schemaReader = New-Object System.Xml.XmlTextReader $SchemaFile
        $schema = [System.Xml.Schema.XmlSchema]::Read($schemaReader, $ValidationEventHandler)
    }

    process {
        $ret = $true
        try {
            $xml = New-Object System.Xml.XmlDocument
            $xml.Schemas.Add($schema) | Out-Null
            $xml.Load($XmlFile)
            $xml.Validate({
                    throw ([PsCustomObject] @{
                        SchemaFile = $SchemaFile
                        XmlFile = $XmlFile
                        Exception = $args[1].Exception
                    })
                })

                Write-Host "XML is valid" -ForegroundColor Green #$ret 

        } catch {
            Write-host "XML is NOT Valid." -ForegroundColor Red
            Write-Error $_
            $ret = $false
        }
        
    }

    end {
        $schemaReader.Close()
    }
}

$xsdPath = "\\B2K-SERVICES\Scripts\pain.001.001.03.xsd"
#dir "\\192.168.131.10\b2kcy\IT\!Pending\1BANKfiles\sample-xml-file-for-payroll-and-group-payments.xml" | Test-XmlFile  $xsdPath
dir $XMLPAth | Test-XmlFile  $xsdPath