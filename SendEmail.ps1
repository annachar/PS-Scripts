param ($subject, $body)


# Get the credential
$username = "helpdesk@b2kapital.com.cy"
$password = "Jaj47981!"
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

$style = "<style>BODY{font-family: Calibri Light; font-size: 10pt;}"
$style = $style + "</style>"


if($body -eq "") { $body = "No files copied"}

$time = Get-Date -Format "HH:mm"
$personalMessage = "Have a nice day!" 

if($time -gt "12:00"  ) {$personalMessage = "Enjoy your evening!"}

$Body = $style + "<body>**Automated message.**<br><br>$body<br><br>$personalMessage</body>"
$Body = $Body + $html

## Define the Send-MailMessage parameters
$mailParams = @{
    SmtpServer                 = 'smtp.office365.com'
    Port                       = '587' # or '25' if not using TLS
    UseSSL                     = $true ## or not if using non-TLS
    Credential                 = $cred
    From                       = 'helpdesk@b2kapital.com.cy'
    To                         = 'ach@b2kapital.com.cy' 
    Subject                    = "$subject - $(Get-Date -Format g)"
    Body                       = $Body 
    DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
}

## Send the message
Send-MailMessage @mailParams -BodyAsHtml