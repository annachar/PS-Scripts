#https://www.quandl.com/data/BOF-Bank-of-France/documentation
#Quandl Codes for BOF Datasets
#NAME	CODE
#EONIA	BOF/QS_D_IEUEONIA
#EURIBOR 1 MONTH	BOF/QS_D_IEUTIO1M
#EURIBOR 3 MONTHS	BOF/QS_D_IEUTIO3M
#EURIBOR 6 MONTHS	BOF/QS_D_IEUTIO6M
#EURIBOR 9 MONTHS	BOF/QS_D_IEUTIO9M
#EURIBOR 12 MONTHS	BOF/QS_D_IEUTIO1A


#EONIA	BOF/QS_D_IEUEONIA
Invoke-RestMethod -Uri https://www.quandl.com/api/v3/datasets/BOF/QS_D_IEUEONIA.csv?api_key=-1boy7Tv75WjEeJdaHxL |  ConvertFrom-Csv | Export-Csv -Path 'C:\Users\ach\Desktop\EURIBOR\QS_D_IEUEONIA.csv' -NoTypeInformation

#EURIBOR 1 MONTH	BOF/QS_D_IEUTIO1M
Invoke-RestMethod -Uri https://www.quandl.com/api/v3/datasets/BOF/QS_D_IEUTIO1M.csv?api_key=-1boy7Tv75WjEeJdaHxL |  ConvertFrom-Csv | Export-Csv -Path 'C:\Users\ach\Desktop\EURIBOR\QS_D_IEUTIO1M.csv' -NoTypeInformation

#EURIBOR 3 MONTHS	BOF/QS_D_IEUTIO3M
Invoke-RestMethod -Uri https://www.quandl.com/api/v3/datasets/BOF/QS_D_IEUTIO3M.csv?api_key=-1boy7Tv75WjEeJdaHxL |  ConvertFrom-Csv | Export-Csv -Path 'C:\Users\ach\Desktop\EURIBOR\QS_D_IEUTIO3M.csv' -NoTypeInformation

#EURIBOR 6 MONTHS	BOF/QS_D_IEUTIO6M
Invoke-RestMethod -Uri https://www.quandl.com/api/v3/datasets/BOF/QS_D_IEUTIO6M.csv?api_key=-1boy7Tv75WjEeJdaHxL |  ConvertFrom-Csv | Export-Csv -Path 'C:\Users\ach\Desktop\EURIBOR\QS_D_IEUTIO6M.csv' -NoTypeInformation

#EURIBOR 9 MONTHS	BOF/QS_D_IEUTIO9M
Invoke-RestMethod -Uri https://www.quandl.com/api/v3/datasets/BOF/QS_D_IEUTIO9M.csv?api_key=-1boy7Tv75WjEeJdaHxL |  ConvertFrom-Csv | Export-Csv -Path 'C:\Users\ach\Desktop\EURIBOR\QS_D_IEUTIO9M.csv' -NoTypeInformation

#EURIBOR 12 MONTHS	BOF/QS_D_IEUTIO1A
Invoke-RestMethod -Uri https://www.quandl.com/api/v3/datasets/BOF/QS_D_IEUTIO1A.csv?api_key=-1boy7Tv75WjEeJdaHxL |  ConvertFrom-Csv | Export-Csv -Path 'C:\Users\ach\Desktop\EURIBOR\QS_D_IEUTIO1A.csv' -NoTypeInformation


#############################################

 function ConvertTo-DataTable {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)]
        [PSObject[]]$InputObject
    )

    Begin {
        $dataTable = New-Object System.Data.DataTable
        $first = $true

        function _GetSafeTypeName($type) {
            # internal helper function to return the correct typename for a datatable
            $types = @('System.Boolean', 'System.Byte', 'System.SByte', 'System.Char', 'System.Datetime',
                       'System.TimeSpan', 'System.Decimal', 'System.Double', 'System.Guid', 'System.Single')
            $ints  = @('System.Int16', 'System.Int32', 'System.Int64')
            $uints = @('System.UInt16', 'System.UInt32', 'System.UInt64')

            if ($types -contains $type) { return "$type" }
            # if the type is Int or UInt, always return the largest variety
            if ($ints  -contains $type) { return 'System.Int64' }
            if ($uints -contains $type) { return 'System.UInt64' }
            return 'System.String'
        }
    }
    Process {
        foreach ($object in $InputObject) {
            $dataRow = $dataTable.NewRow()
            foreach($property in $object.PSObject.Properties) {
                # read the data type for this property and make sure it is a valid type for a DataTable
                $dataType = _GetSafeTypeName $property.TypeNameOfValue
                # ensure the property name does not contain invalid characters
                $propertyName = $property.Name -replace '[\W\p{Pc}-[,]]', '_' -replace '_+', '_'
                if ($first) {
                    $dataColumn = New-Object System.Data.DataColumn $propertyName, $dataType
                    $dataTable.Columns.Add($dataColumn)
                }
                if ($property.Gettype().IsArray -or ($property.TypeNameOfValue -like '*collection*')) {
                    $dataRow.Item($propertyName) = $property.Value | ConvertTo-XML -As String -NoTypeInformation -Depth 1
                }
                else {
                    $value = if ($null -ne $property.Value) { $property.Value } else { [System.DBNull]::Value }
                    $dataRow.Item($propertyName) = $value -as $dataType
                }
            }
            $dataTable.Rows.Add($dataRow)
            $first = $false
        }
    }
    End {
        Write-Output @(,($dataTable))
    }
}