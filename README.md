# Microsoft Exchange useful PowerShell commands

## Exchange online (Office 365)

### [Install on Windows](https://www.techielass.com/install-exchange-online-powershell-modules)

```PowerShell
Install-Module PowerShellGet -Force
Install-Module -Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
```

### [Install on MacOS with Homebrew](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.3)

- `brew install --cask powershell`
- use `pwsh`

### Open and close connection with Office 365

Connecting: `Connect-ExchangeOnline -UserPrincipalName <ADMIN_EMAIL>`

The command invokes a pop-up window to enter your password.

Closing connection: `Disconnect-ExchangeOnline`

### Open and close connection with On-premise

- Run PowerShell "As administator"
- `$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://EXCHANGE_ADDRESS/PowerShell/ -Authentication Kerberos -Credential (Get-Credential)`
- `Import-PSSession $Session -DisableNameChecking`

Close connection:
- Remove-PSSession $Session

## Mailbox info

Show all mailboxes without soft-deleted ones: `Get-Mailbox`

Show all mailboxes including soft-deleted ones: `Get-Mailbox -SoftDeleted`

Show mailbox folder sizes without so-called 'Recoverable Items'
```PowerShell
Get-MailboxFolderStatistics <USER_ALIAS> | Format-List Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders
```

Show 'In-place archive' mailbox folder sizes without so-called 'Recoverable Items'
```PowerShell
Get-MailboxFolderStatistics <USER_ALIAS> -Archive | Format-List Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders
```

Show mailbox folder sizes including 'Recoverable Items`
```PowerShell
Get-MailboxFolderStatistics <USER_ALIAS> -FolderScope RecoverableItems | Format-List Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders
```

> Use with caution!
> Source: https://o365info.com/force-delete-mailbox/
>
> Remove soft-deleted mailbox (Azure AD account must be deleted beforehand)
> ```PowerShell
> Get-Mailbox -Identity <USER_EMAIL> -SoftDeletedMailbox | Remove-Mailbox -PermanentlyDelete -Force -Confirm:$false
> ```

## Connected mobile devices

`Get-MobileDevice | select userDisplayName,friendlyname,DeviceIMEI,DeviceOs,DeviceUserAgent | Format-Table`

## Address book

Source: https://www.howto-outlook.com/howto/oabupdate.htm

### Show Exchange OAB address book:

`Get-Mailbox -Arbitration -Filter "PersistedCapabilities -eq 'OrganizationCapabilityOABGen'"`

### Update Exchange Global Address List:
```PowerShell
Get-GlobalAddressList | Update-GlobalAddressList
Get-OfflineAddressbook | Update-OfflineAddressbook
Get-ClientAccessServer | Update-FileDistributionService

Get-AddressList | Update-AddressList
```

## Comliance search

Source links:
- https://learn.microsoft.com/en-us/purview/ediscovery-search-for-and-delete-email-messages
- https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell?view=exchange-ps
- https://learn.microsoft.com/en-us/powershell/module/exchange/new-compliancesearch?view=exchange-ps

Connecting the Purview Compliance portal:
```PowerShell
Connect-IPPSSession -UserPrincipalName <ADMIN_EMAIL>
```

Search for emails:
```PowerShell
$Search=New-ComplianceSearch -Name "August 2023 emails" -ExchangeLocation <SEARCHED_EMAIL> -ContentMatchQuery '(Received:8/1/2023..8/31/2023)'
Start-ComplianceSearch -Identity $Search.Identity
```

## [Migration from Office365 to on-premise Exchange server](https://learn.microsoft.com/en-us/powershell/module/exchange/get-migrationuserstatistics?view=exchange-ps)

Watch the migrations status of a mailbox
```PowerShell
Get-MigrationUserStatistics -Identity <EMAIL> | Select-Object EstimatedTotalTransferSize,BytesTransferred,TotalItemsInSourceMailboxCount,TransferredItemCount,SyncedItemCount,SkippedItemCount,PercentageComplete | Format-List
```

Super detailed info:
```PowerShell
Get-MigrationUserStatistics -Identity <EMAIL> -DiagnosticInfo "verbose,showtimeslots,showtimeline,status,reports,endpoints" -IncludeReport | Format-List
```

## Tricky way to delete emails from 'Recoverable items'

Prerequisites:
1. Set zero days to the `retainDeletedItemsFor` option (duration between deleteing emails from Outlooks's Recycle bin to 'Recoverable items', up to actual deletion of the emails):
```PowerShell
Set-Mailbox -Identity <USER_ALIAS> -retainDeletedItemsFor 0
```
2. Create an 'Archive tag' (a rule) with the action 'Move to archive': https://compliance.microsoft.com/exchangeinformationgovernance?viewid=exoRetentionPolicyTag
3. Create an archiving Policy of 'In-place archiving' using the created Archive tag: https://compliance.microsoft.com/exchangeinformationgovernance?viewid=exoRetentionPolicy

The process:
1. Allow mailbox to have 'In-place archive': `Enable-Mailbox -Identity <USER_ALIAS> -Archive`
2. Apply the policy of 'In-place archiving':
```PowerShell
Start-ManagedFolderAssistant -Identity <USER_ALIAS>
```
4. Watch for the size of the archive to grow up:
```PowerShell
Get-MailboxFolderStatistics <USER_ALIAS> -FolderScope RecoverableItems -Archive | Format-List Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders
Get-MailboxFolderStatistics <USER_ALIAS> -FolderScope RecoverableItems | Format-List Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders
```
5. Delete the 'In-place archive': `Disable-Mailbox -Identity <USER_ALIAS> -Archive`.
6. Repeat the steps 1-5 because, for some reason, there is a strange limit of email deletion.

# Miscellaneous
Erase information of the Office365 online mailbox in on-premise Exchange: `Disable-RemoteMailbox <USER_ALIAS>`

Force AD to synchronize with Office365 Azure AD: `Start-ADSyncSyncCycle -PolicyType Initial`
