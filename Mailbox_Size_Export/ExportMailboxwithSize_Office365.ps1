# Sorts mailboxes by size and exports to CSV 
get-mailbox -ResultSize Unlimited | 
Get-MailboxStatistics | 
select displayname,@{n="Total Size (MB)";e={[math]::Round( ` 
($_.totalitemsize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),1)}} | 
sort "Total Size (MB)" -Descending | 
export-csv "D:\Tejas\Mailbox_Size_Export\MailboxSizeReport.csv" -NoTypeInformation