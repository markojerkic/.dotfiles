oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/larserikfinholt.omp.json" | Invoke-Expression
Import-Module posh-git

function Invoke-FuzzyEditDev {Invoke-FuzzyEdit ~\Dev}
Set-Alias -Name fe -Value Invoke-FuzzyEditDev
function Invoke-FuzzySetLocationDev {Invoke-FuzzySetLocation ~\Dev}
Set-Alias -Name fs -Value Invoke-FuzzySetLocationDev

