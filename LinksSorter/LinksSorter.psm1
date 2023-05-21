function GetMainMenuItems
{
    param(
        $getMainMenuItemsArgs
    )

    $menuItem1 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem1.Description = [Playnite.SDK.ResourceProvider]::GetString("LOCLinks_Sorter_MenuItemFormatSelectedDescription")
    $menuItem1.FunctionName = "Format-SelectedGames"
    $menuItem1.MenuSection = "@Links Sorter"
    
    $menuItem2 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem2.Description = [Playnite.SDK.ResourceProvider]::GetString("LOCLinks_Sorter_MenuItemFormatAllDescription")
    $menuItem2.FunctionName = "Format-AllGames"
    $menuItem2.MenuSection = "@Links Sorter"
    
    return $menuItem1, $menuItem2
}

function Format-Links
{
    param (
        $GameDatabase
    )

    $SortedGames = 0
    foreach ($Game in $GameDatabase) {
        $SortedLinks = $Game.Links | Sort-Object -Property @{Expression = "Name"; Descending = $false}
        $SortedLinkOrder = $SortedLinks | Select-Object -Property Name | Out-String
        $OriginalLinkOrder = $Game.Links | Select-Object -Property Name | Out-String
        if ($OriginalLinkOrder -ne $SortedLinkOrder)
        {
            $Game.Links = $SortedLinks
            $PlayniteApi.Database.Games.Update($game)
            $SortedGames++
        }
    }
    
    # Show finish dialogue with sorted games count
    $PlayniteApi.Dialogs.ShowMessage(([Playnite.SDK.ResourceProvider]::GetString("LOCLinks_Sorter_ResultsMessage") -f $SortedGames), "Links Sorter");
}

function Format-SelectedGames
{
    param(
        $scriptMainMenuItemActionArgs
    )
    
    # Set GameDatabase
    $GameDatabase = $PlayniteApi.MainView.SelectedGames | Where-Object {$_.Links}
    
    Format-Links $GameDatabase
}

function Format-AllGames
{
    param(
        $scriptMainMenuItemActionArgs
    )
    
    # Set GameDatabase
    $GameDatabase = $PlayniteApi.Database.Games | Where-Object {$_.Links}
    
    Format-Links $GameDatabase
}