<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#>


#requries -Version 2.0

<#
 	.SYNOPSIS
        This script will remove a custom domain in Office 365.
    .DESCRIPTION
        This script will remove a custom domain in Office 365.
    .PARAMETER  Credential
        Used to log into Exchange Online service.
    .PARAMETER  Domains
        This parameter specifies the Domain to be removed
    .EXAMPLE
       RemoveDomainO365.ps1 -Credential $Credential –Domain “Contoso.com” 
       Remove custom domain contoso.com from Office 365 
#>

Param
(
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$Credential,
    [Parameter(Mandatory=$true)]
    [String]$Domain
)

Begin
{
    $exitingSnaping = Get-PSSnapin -Verbose:$false | Where-Object {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"}
    $existingSession = Get-PSSession -Verbose:$false | Where-Object {(($_.ConfigurationName -eq "Microsoft.Exchange") -and ($_.ComputerName -notlike "*outlook.com" ))}
    if(($exitingSnaping -ne $null) -or ($existingSession -ne $null) )
    {
        Write-Error "Please run a PowerShell instance instead of running Exchange Management Shell"
        Exit
    }
    Try
	{
		#If the remote powershell session does not exist, create a new session.
		$existingSession = Get-PSSession -Verbose:$false | Where-Object {($_.ConfigurationName -eq "Microsoft.Exchange") -and ($_.ComputerName -like "*outlook.com" )}
		if ($existingSession -eq $null) 
        {
			$verboseMsg = "Creating a new session to https://ps.outlook.com/powershell."
			$pscmdlet.WriteVerbose($verboseMsg)
			$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange `
			-ConnectionUri "https://ps.outlook.com/powershell" -Credential $Credential `
			-Authentication Basic -AllowRedirection
			#If session is newly created, import the session.
			Import-PSSession -Session $O365Session -Verbose:$false
			$existingSession = $O365Session
		} 
        else 
        {
			$verboseMsg = "Found existing session, new session creation is skipped."
			$pscmdlet.WriteVerbose($verboseMsg)
		}
    }
    Catch
	{
		write-error $Error[0]
        exit
	}


   Try
    {
        import-module MSOnline
    }
    Catch
    {
        write-error "Please install Windows Azure Active Directory Module for Windows PowerShell"
        exit
    }
    Connect-MsolService -Credential $Credential
}

Process
{
    #need to deal with the sub domain if remove the root domain
    $domains =  get-msoldomain
    if($domains.name -notcontains $Domain)
    {
        Write-Error "This domain is not existed in this tenant"
        Exit
    }

    $reg = New-Object System.Text.RegularExpressions.Regex("\w+\.$Domain","IgnoreCase")
    foreach($d in $domains)
    {
        if(($reg.match($d.name).success) -eq "TRUE")
        {
            Write-Error "Please remove the sub domain first"
            Exit
        }
    }

 #   [regex]$reg = "\w+\.onmicrosoft\.com"
    $reg = New-Object System.Text.RegularExpressions.Regex("\w+\.onmicrosoft\.com","IgnoreCase")
    foreach($d in $domains)
    {
        if(($reg.match($d.name).success) -eq "TRUE")
        {
            $Tenantdomain = $reg.Match($d.name).Value
        }
    }


    $UserList = Get-MsolUser -DomainName $Domain
    [regex]$reg = ".+(?=@)"
    foreach($User in $UserList)
    {
        $UserName = $reg.Match($User.UserPrincipalName).Value
        $NewName = $UserName + "@" + $Tenantdomain
        $Existed = $null
        $Existed = Get-MsolUser -UserPrincipalName $NewName
        $i = 1
        while($Existed -ne $null)
        {
            $Existed = $null
            $UserName = $reg.Match($User.UserPrincipalName).Value
            $Username = $UserName + "." + $i
            $NewName = $UserName + "@" + $Tenantdomain
            $Existed = Get-MsolUser -UserPrincipalName $NewName
        }
        Set-MsolUserPrincipalName -UserPrincipalName $User.UserPrincipalName -NewUserPrincipalName $NewName
    }

    $MailboxList = Get-Mailbox
    $reg = New-Object System.Text.RegularExpressions.Regex(".+@$Domain","IgnoreCase")
    [regex]$reg = ".+@" + $Domain
    Foreach($Mailbox in $MailboxList)
    {
        Foreach($Address in $Mailbox.EmailAddresses)
        {
            if($reg.match($Address).Success -eq "TRUE")
            {
                $Mailbox.EmailAddresses.remove($Address)
            }
        }
        Set-Mailbox -identity $Mailbox.PrimarySmtpAddress -EmailAddresses $mailbox.EmailAddresses
    }


    $DGList = Get-DistributionGroup
    Foreach($DG in $DGLIst)
    {
        Foreach($Address in $DG.EmailAddresses)
        {
            if($reg.match($Address).Success -eq "TRUE")
            {
                $DG.EmailAddresses.remove($Address)
            }
        }
        Set-DistributionGroup -identity $DG.PrimarySmtpAddress -EmailAddresses $DG.EmailAddresses -BypassSecurityGroupManagerCheck
    }

    $DDGList = Get-DynamicDistributionGroup
    Foreach($DDG in $DDGLIst)
    {
        Foreach($Address in $DDG.EmailAddresses)
        {
            if($reg.match($Address).Success -eq "TRUE")
            {
                $DDG.EmailAddresses.remove($Address)
            }
        }
        Set-DynamicDistributionGroup -identity $DDG.PrimarySmtpAddress -EmailAddresses $DDG.EmailAddresses -BypassSecurityGroupManagerCheck
    }



    Remove-MsolDomain $Domain

}

End
{}