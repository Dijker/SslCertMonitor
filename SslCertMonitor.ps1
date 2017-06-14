<#
.SYNOPSIS
	Test SSL Certificate(s) Expiry.
	
.DESCRIPTION
	Verify expiration of SSL certificate and send mail alert if under threshold.
	
.PARAMETER ShowMessage
	Output message to screen. (Doesn't affect e-mail functionnality)

.PARAMETER SendTestEmail
	Send a test e-mail to the configured e-mails ERROR.

.EXAMPLE
	.\SslCertMonitor.ps1
	
	Normal run built to be executed by a scheduled task.
	
.EXAMPLE
	.\SslCertMonitor.ps1 -ShowMessage
	
	To see on-screen output when script is runned manually.
	
.EXAMPLE
	.\SslCertMonitor.ps1 -SendTestEmail
	
	To execute the script in e-mail test mode.
	
.NOTES
	Version :	1.0.0.0
	Author  :	Gr33nDrag0n
	History :	2017/06/13 - v1.0.0.0 Last Modification
#>

###########################################################################################################################################
### Parameters
###########################################################################################################################################

[CmdletBinding()]
Param(
	[parameter( Mandatory=$False )]
	[switch] $ShowMessage,
	
	[parameter( Mandatory=$False )]
	[switch] $SendTestEmail
	)

###########################################################################################################################################
### Host Initialization
###########################################################################################################################################

[System.GC]::Collect()
$error.Clear()

# Disabling the cert. validation check for invalid certs support.
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}


#######################################################################################################################
# Configurable Variables | MANDATORY !!! EDIT THIS SECTION !!!
#######################################################################################################################

$Private:Banner = "SslCertMonitor v1.0 by Gr33nDrag0n"
$Private:MinimumCertAgeDays = 14
$Private:TimeoutMilliseconds = 3000

### URL List ###============================================================================

$Private:UrlList = @()

$UrlList += 'https://www.lisknode.io'
$UrlList += 'https://www.arknode.net'
$UrlList += 'https://lisk.io'
$UrlList += 'https://ark.io'
$UrlList += 'https://lisktools.io'

### E-Mail ###===============================================================================

$Private:Email = @{}

$Email.SenderEmail      = 'SslCertMonitor@mydomain.com'
# Same SMTP address you would use in your e-mail client
$Email.SenderSmtp       = 'smtp.myISP.com'
$Email.SendErrorMail    = $True
$Email.ErrorEmailList   = @('myemail@domain.com','my-2nd-optional-email@domain.com')


###########################################################################################################################################
# MAIN
###########################################################################################################################################

if( $SendTestEmail )
{
	Write-Host "`r`n$Banner`r`n`r`n" -ForegroundColor Green
	Write-Host 'Sending Test Email(s)...'
	
	if( $Email.SendErrorMail -eq $True )
	{
		Send-MailMessage -SmtpServer $Email.SenderSmtp -From $Email.SenderEmail -To $Email.ErrorEmailList -Subject 'SslCertMonitor' -Body 'SslCertMonitor (SendTestEmail)' -Priority High
	}
	else
	{
		Write-Host '$Email.SendErrorMail is set to False, Skipping ERROR Email Test.'
	}
	
	Write-Host "Done`r`n"
}
else
{
	if( $ShowMessage ) { Write-Host "`r`n$Banner`r`n`r`n" -ForegroundColor Green }
	
	$Private:AlertMessage = ''

	ForEach( $Private:Url in $UrlList )
	{
		Try
		{
			$Private:Request = [System.Net.HttpWebRequest]::Create($Url)
			$Request.Timeout = $TimeoutMilliseconds
		}
		Catch
		{
			Write-Warning "Invalid URL! => $Url"
		}

		
		if( $Request )
		{
			Try
			{
				$Request.GetResponse().Dispose()
				$Certificate = $Request.ServicePoint.Certificate		

			}
			Catch
			{
				Write-Warning "Fetching of the certificate FAILED! => $Url"
			}
		}
		
		if( $Certificate )
		{
			#$Private:CertInfo = @{}
			
			#$CertInfo.Address = $Url
			#$CertInfo.Subject = $Certificate.Subject
			#$CertInfo.Name = $Certificate.GetName()
			#$CertInfo.EffectiveDate = $Certificate.GetEffectiveDateString()
			#$CertInfo.ExpirationDate = $Certificate.GetExpirationDateString()
			#$CertInfo.ExpirationDayCount = ( $( [datetime]$CertInfo.ExpirationDate ) - $( Get-Date ) ).Days
			#$CertInfo.Issuer = $Certificate.GetIssuerName()
			#$CertInfo.KeyAlgorithm = $Certificate.GetKeyAlgorithm()
			#$CertInfo.KeyAlgorithmParameters = $Certificate.GetKeyAlgorithmParametersString()
			#$CertInfo.PublicKey = $Certificate.GetPublicKeyString()
			#$CertInfo.RawCert = $Certificate.GetRawCertDataString()
			#$CertInfo.Serial = $Certificate.GetSerialNumberString()
			#$CertInfo.Hash = $Certificate.GetCertHashString()
			
			$Private:ExpirationDate = $Certificate.GetExpirationDateString()
			$Private:DayCount = ( $( [datetime]$ExpirationDate ) - $( Get-Date ) ).Days

			if( $DayCount -le $MinimumCertAgeDays )
			{
				$AlertMessage += "$DayCount day(s) left for $Url`r`n"
				if( $ShowMessage ) { Write-Host "$DayCount | $Url" -ForegroundColor Red }
			}
			else
			{
				if( $ShowMessage ) { Write-Host "$DayCount | $Url" -ForegroundColor Green }
			}
		}
	}

	### E-mail Reporting ###=======================================================================================

	if( $Email.SendErrorMail -eq $True )
	{
		if( $AlertMessage -ne '' )
		{
			if( $ShowMessage ) { Write-Host "`r`nExpiring certificate(s) detected, sending alert mail.`r`n" -ForegroundColor Red }
			
			Send-MailMessage -SmtpServer $Email.SenderSmtp -From $Email.SenderEmail -To $Email.ErrorEmailList -Subject 'SslCertMonitor Alert' -Body $AlertMessage -Priority High
		}
		else
		{
			if( $ShowMessage ) { Write-Host "`r`nNo expiring certificate(s) detected, skipping alert mail.`r`n" -ForegroundColor Green }
		}
	}
	else
	{
		if( $ShowMessage ) { Write-Host '`r`nSendErrorMail = $False, Skipping Email/SMS.`r`n' -ForegroundColor Yellow }
	}
}
