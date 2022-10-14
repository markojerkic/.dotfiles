oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/marcduiker.omp.json" | Invoke-Expression
Import-Module posh-git
Import-Module PSFzf

# Search directory
$startLocation = $Env:StartLocation.Trim();
if (-not($startLocation)) {
    Write-Error "Export StartLocation env variable";
    exit 1;
}

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

function Invoke-FuzzyEditDev {Invoke-FuzzyEdit $startLocation }
Set-Alias -Name fe -Value Invoke-FuzzyEditDev

function Invoke-FuzzySetLocationDev { c:\stribog.exe -u -r "C:\" -f node_modules -f ".git" -f ".next" -f ".mvn" -f ".swc" -f build -f target  -f AppData -f "android" -f "apache-maven-3.8.5" -f "DownLoadiTunes" -f "Drivers" -f "ESD" -f "Log" -f "MinGW" -f "PerfLogs" -f "Program Files" -f "Program Files (x86)" -f "pscale_0.93.0_windows_arm64" -f "Python27" -f "Python39" -f "Riot Games" -f "Ruby26-x64" -f "Windows" -f temp -f ProgramData -f "$" -f dist  | Invoke-fzf | Set-Location }
Set-Alias -Name fs -Value Invoke-FuzzySetLocationDev

function Invoke-FuzzyGitSwitch { git branch |  % {$_.replace("*","")} | % {$_.replace(" ","")} | Invoke-Fzf | % {git switch $_} }
Set-Alias -Name fg -Value Invoke-FuzzyGitSwitch

function Invoke-FuzzyGitSwitchRemote { git branch -r |  % {$_.replace("*","")} | % {$_.replace(" ","")} | Invoke-Fzf | % {git checkout $_ -t } }
Set-Alias -Name fgr -Value Invoke-FuzzyGitSwitchRemote

function Invoke-FuzzyGitSwitchDelete { git branch |  % {$_.replace("*","")} | % {$_.replace(" ","")} | Invoke-Fzf | % {git branch -d $_ } }
Set-Alias -Name fgd -Value Invoke-FuzzyGitSwitchDelete 

function Invoke-FuzzyGitSwitchDeleteForce { git branch |  % {$_.replace("*","")} | % {$_.replace(" ","")} | Invoke-Fzf | % {git branch -D $_ } }
Set-Alias -Name fgdf -Value Invoke-FuzzyGitSwitchDeleteForce

function Invoke-GitSwitch { git switch -c $args[0] }
Set-Alias -Name gs -Value Invoke-GitSwitch 

function Invoke-GitStatus { git status }
Set-Alias -Name g -Value Invoke-GitStatus 

function Invoke-GitAddPartial { git add -p . }
Set-Alias -Name gap -Value Invoke-GitAddPartial 

function Invoke-ProfileUpdate { curl "https://raw.githubusercontent.com/markojerkic/.dotfiles/main/Microsoft.Powershell_profile.ps1" > $PROFILE; . $PROFILE }
Set-Alias -Name up -Value Invoke-ProfileUpdate 
