# Migrate users between Sharepoint domains

The code below based on a [Sharepoint Diary article](https://www.sharepointdiary.com/2014/12/migrate-sharepoint-users-from-one-domain-to-another.html#ixzz7wOWiVaL8)

```PowerShell

Add-PSSnapin Microsoft.SharePoint.PowerShell

$PORTAL_URL ="https://portal"
$UserDataRows = Import-CSV -path "..\desktop\spusers.csv" -Delimiter ';'
 
foreach ($UserDataRow in $UserDataRows) {
	$OldUserID = $UserDataRow.OldUserID.Trim()
	$NewUserID = $UserDataRow.NewUserID.Trim()
	$Email = $UserDataRow.Email.Trim()

    write-host "Processing user:" $Email
 
    #Site collection URL
    $sharepointSite = Get-SPSite $PORTAL_URL
 
    foreach($webSite in $sharepointSite.AllWebs)
    {
        $WebSiteUsers = Get-SPUser -web $webSite.Url
 
        foreach ($WebSiteUser in $WebSiteUsers)
        {
            if ($WebSiteUser.UserLogin.Contains($OldUserID))
            {
                #Update the User E-mail
                Set-SPUser -Identity $WebSiteUser.UserLogin -Email $Email -Web $webSite.Url
 
                $NewUser = $WebSiteUser.UserLogin.replace($OldUserID, $NewUserID)
 
                #Migrate user from Old account to new account - migrate users to new domain
                Move-SPUser -Identity $WebSiteUser -NewAlias $NewUser -IgnoreSID -confirm:$false
                write-host "User Migrated: $($User.userlogin) at site $($web.Url)"
            }       
        }
    }
}
```
