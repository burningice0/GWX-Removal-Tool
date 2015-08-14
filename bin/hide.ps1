$update = "KB3035583" 
write-host "Start searching for updates. This may take several minutes..." 
$updates = ((New-Object -Com "Microsoft.Update.Session").CreateUpdateSearcher()).Search("IsInstalled=0") 
$updates.Updates | %{ 
    If($_.Title -like "*$update*"){ 
    write-host "Hiding $($_.Title)" 
    $_.IsHidden = $true 
    } 
}
