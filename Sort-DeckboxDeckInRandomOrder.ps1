$strFileName = Join-Path '.' 'Teferi, Timeless Voyager (Core Set 2021 Planeswalker Deck)_franklesniak_2020.November.27.csv'

$arrExportedDeckListingFromDeckbox = @(Import-Csv -Path $strFileName)

$arrDeckOfCards = @($arrExportedDeckListingFromDeckbox |
    ForEach-Object {
        $PSCustomObjectThisCardListing = $_
        $intCountOfThisCardInDeck = [int]($PSCustomObjectThisCardListing.Count)
        for ($intCounterA = 0; $intCounterA -lt $intCountOfThisCardInDeck; $intCounterA++) {
            $PSCustomObjectThisCardListing.Name
        }
    })

$arrDeckOfCards | Sort-Object { Get-Random }
