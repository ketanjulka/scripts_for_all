$cred = get-credential

Connect-MsolService -Credential $cred

$Users = Get-Msoluser -all

$results = ForEach ($user in $users) {
 ForEach ($license in $user.licenses.servicestatus) {
  $props = @{'UPN'=$user.userprincipalname
             'Name' = $license.ServicePlan.ServiceName
             'Status' = $license.ProvisioningStatus}

  New-Object -Type PSObject -Prop $props
 }
} 

$results | where {$_.status -eq "Enabled" -and $_.name -eq "YAMMER_ENTERPRISE"}