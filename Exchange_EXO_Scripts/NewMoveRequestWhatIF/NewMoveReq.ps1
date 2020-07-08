$remote=get-credential xyz\eitO365svc
Import-Csv 'D:\Ketan\NewMoveRequestWhatIF\NewMoveRequestWhatif.csv'
ForEach {New-MoveRequest -Identity $_.Identity -Remote -RemoteHostName "hybrid.xyz.com" -TargetDeliveryDomain "xyzgroup.mail.onmicrosoft.com" -RemoteCredential $remote -WhatIf
}



