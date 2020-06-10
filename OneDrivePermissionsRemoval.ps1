Function Remove-OneDriveSharingLink {
param (
	$OneDriveURL="https://xyz.sharepoint.com"   
      )   
process{
 	
        Connect-PnPOnline -Url $OneDriveURL
        $Ctx= Get-PnPContext
     
        $Files= Get-PnPListItem -List "documents"
        foreach( $File in $Files)
          {       
                $Froles= $File.RoleAssignments
                $Ctx.load($Froles)
                $Ctx.ExecuteQuery()
                 
                If($Froles.Count -gt 0)
                {
                 
                  for ($i = $Froles.Count -1; $i -ge 0 ; --$i)  
                   {   
                      $Link=$Froles[$i].Member
                      $Ctx.Load($Link)
                      $Ctx.ExecuteQuery()
                      If($Link.title -like "SharingLinks*")
                      {
                       $Froles[$i].DeleteObject()
                      }
                      $Link = $null
                   }  
                  $Ctx.ExecuteQuery()           
                 }      
          }
      }
  }
 
Remove-OneDriveSharingLink -OneDriveURL "https://xyz.sharepoint.com/personal/tom_xyz_com"