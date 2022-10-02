oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/larserikfinholt.omp.json" | Invoke-Expression
Import-Module posh-git

$startLocation = $args[0].ToString().Trim();

function Invoke-FuzzyEditDev { Invoke-FuzzyEdit $startLocation }
Set-Alias -Name fe -Value Invoke-FuzzyEditDev

function Invoke-FuzzySetLocationDev { get-childitem -Path $startLocation -name -depth 3 -Directory | Where-Object { -not($_.contains("\node_modules")) } | Where-Object { -not($_.contains("\.")) } | Where-Object { -not($_.contains("\yarn")) } | Invoke-Fzf | % { "$startLocation\$_" } | Set-Location }
Set-Alias -Name fs -Value Invoke-FuzzySetLocationDev

function Invoke-PsFzfGitBranchesDev { git branch | Invoke-Fzf | % { $_.replace(" ", "") } | % { $_.replace("*", "") } | % { git switch $_ } }
Set-Alias -Name fg -Value Invoke-PsFzfGitBranchesDev
