function Encrypt-File {
	<#
		.SYNOPSIS
			Encrypts one or more files using AES256
		.DESCRIPTION
			Encrypts files using AES256 using GPG as backend.
			The encrypted file is stored in the same directory
			as the given file with .gpg suffix. If such a file
			already exists, it will be overwritten.
		.INPUTS
			Path(s) to files to be encrypted
		.OUTPUTS
			Path(s) to encrypted files
	#>
	[CmdletBinding(DefaultParameterSetName='ManualPassphrase')]
	param(
		# Path(s) to files to be encrypted
		[Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
		[string[]] $Path,

		# Path to passphrase file
		[Parameter(Mandatory=$true, ParameterSetName='ManualPassphrase')]
		[string] $PassphraseFile,

		# Generates a passphrase file pass.txt automatically for encrypting
		[Parameter(Mandatory=$true, ParameterSetName='AutoPassphrase')]
		[switch] $GeneratePassphraseFile
	)

	begin {
		Get-Command gpg -ErrorAction Stop | Out-Null

		if ($PSCmdlet.ParameterSetName -eq 'AutoPassphrase' -and $GeneratePassphraseFile) {
			Get-Command keepassxc-cli -ErrorAction Stop | Out-Null
			keepassxc-cli generate | Out-File 'pass.txt'
			$passFile = 'pass.txt'
		} elseif ($PSCmdlet.ParameterSetName -eq 'ManualPassphrase') {
			$passFile = $PassphraseFile
		}
	}

	process {
		#foreach($pth in $Path) {
        $items = Get-ChildItem -Path $Path
        foreach ($item in $items)
        {
			#$pthitem = Get-Item $pth
			#$outfile = $pthitem.FullName + '.pgp'
			$outfile = $item.FullName + '.pgp'
            if (Test-Path -LiteralPath $outfile -PathType Leaf) {
				Remove-Item $outfile
				Write-Verbose "Overwriting existing file $outfile"
			}
			#gpg --batch --passphrase-file $passFile --cipher-algo AES256 --digest-algo SHA512 -o $outfile -c $pth
            gpg --cipher-algo AES256 --digest-algo SHA512 --default-key CAC_B2KAPCY  --output $outfile  --recipient CAC_CBC --sign --encrypt $item.FullName

			$outfile
		}
	}
}




$path = "C:\Users\administrator.B2KAPITALCY\Desktop\Temp Files CBC\*"
$pathKey = "C:\Users\administrator.B2KAPITALCY\Desktop\Temp Files CBC Key\key.txt"

Encrypt-File -Path $path -PassphraseFile $pathKey