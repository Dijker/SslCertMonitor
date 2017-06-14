Stand-alone PowerShell script to do end-user monitoring on SSL certificate(s) expiration date.
It uses PowerShell so it run only on Windows.

## **Installation**

Save a copy of SslCertMonitor.ps1

This README use this path C:\Scripts\SslCertMonitor.ps1, adjust accordingly if you use something else.

## **Configuration, Manual Usage & Testing**

Open the script in your favorite text editor. Basic Notepad WILL work but not recommended. I recommend notepad++ available for free [HERE](https://notepad-plus-plus.org/).

Scroll to line #61

> Configurable Variables | MANDATORY !!! EDIT THIS SECTION !!!

The configuration is splitted in sub-sections:

 - Url List
 - E-mail

### **Configuring URL Section**

Replace the example domains by the urls you want to monitor.
 
### **Configuring E-mail Section**

In this section we will configure the address used to send and received the monitoring automatic e-mails.

Config.          | Description                                                                    | Value Example
------------     | -------------                                                                  | -------------
SenderEmail      | This is the e-mail that will be used as sender by the script.                  | = 'LiskMonitor@mydomain.com'
SenderSmtp       | This is the domain or IP address the script will use as SMTP to send messages. | = 'smtp.myinternetprovider.com'
SendErrorMail    | Enable/Disable the sending of errors messages.                                 | = $True
ErrorEmailList   | E-mail List                                                                    | = @('home@mydomain.com', '1234567890@phoneprovider.com')
 
#### Test E-mail Configuration

`.\SslCertMonitor.ps1 -SendTestEmail`

#### Run manually the check

`.\SslCertMonitor.ps1 -ShowMessage`

##**Scheduled Task(s) Creation & Testing**

The script do a check and send e-mail if necessary.

It's not a program, so like you would use crontab in Linux, you need to use Task Scheduler in Windows

Open Task Scheduler and Create a New Task. (Use Full GUI not the Wizard)

General -> Name: SslCertMonitor

General -> Execute even if user is not connected

Trigger -> New

			* Daily (Adjust Time of Execution)
			
Action  -> New

			* Command:          C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
			* Arguments:        C:\Scripts\SslCertMonitor.ps1
			* WorkingDirectory: C:\Scripts\

## **Troubleshooting & Common Error(s)**

**It doesn’t work.**

Verify PowerShell version installed in your computer. Execute the following command:

> $PSVersionTable

The PSVersion must be at least v4.x.
If not, go [HERE](https://www.microsoft.com/en-us/download/details.aspx?id=40855), select your language, download, install and reboot.

When done re-run the test to confirm your version is now v4.x or upper.

**Script is asking confirmation to execute when running it.**

`Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass`

