# Step 2 : this script downloads reference pdf files and appropriate q file from github
Write-host "Start ..."
$scriptpath = $MyInvocation.MyCommand.Path
$currentdir = Split-Path $scriptpath
Write-host "Current Directory : $currentdir"
Write-host "Script Directory : $PSScriptRoot"
Write-host "Full Script Directory : $PSCommandPath"
#$directorypath = (Get-Item -Path ".\").FullName
#echo "Directory Path : $directorypath"



#If you're calling native apps, you need to worry about [Environment]::CurrentDirectory 
#and not about PowerShell's $PWD current directory.
#Push-Location $MyInvocation.MyCommand.Path # temporarily change to the correct folder
#[Environment]::CurrentDirectory = $PWD
##  Your Script Code ...
#Pop-Location # now back to previous directory
#[Environment]::CurrentDirectory = $PWD
#Final note: $PWD isn't always a legal CurrentDirectory (you might CD into the registry provider for instance), 
#so if you want to put this into your prompt, or into wrapper functions for the *-Location cmdlets, you need to use:
#[Environment]::CurrentDirectory = Get-Location -PSProvider FileSystem



function DownloadFile {
Param(
    [string]$url,
    [string]$savedfilepath
    )
    if (-not(Resolve-Path $savedfilepath)) {
        $webclient = new-object System.Net.WebClient
        $webclient.DownloadFile($url,$savedfilepath)
        #$webclient.DownloadFileAsync($url,$savedfilepath)
        echo "Saved : $savedfilepath"
    } else {
        echo "Skip : $savedfilepath"
    }
}

#a. create folders 'tick' and 'references'
$targetdir = 'References'
if(-not(Test-Path -Path $targetdir )){
    New-Item -ItemType directory -Path $targetdir
}


#b. download tickerplant code from github


#c. download reference pdf files
#to track download progress https://github.com/honzakuzel1989/examples/blob/master/PS1/download-event.ps1
#c1. tickerplants
DownloadFile -url "https://code.kx.com/q/wp/building_real_time_tick_subscribers.pdf" -savedfilepath "$directorypath\1. Building Realtime Tick Subscribers - Nathan Perrem.pdfù"

#c2. gateways and loadbalancing
DownloadFile -url "https://code.kx.com/q/wp/common_design_principles_for_kdb_gateways.pdf" -savedfilepath "$directorypath\2. Common Design Principles for KDB Gateways - Michael McClintock.pdfù"



#d. download console2 in current directory and unzip
$console2zip = 'console2_64bit.zip'
if (-not(Resolve-Path $console2zip)) {
    $uri = 'http://downloads.sourceforge.net/project/console/console-devel/2.00/Console-2.00b148-Beta_64bit.zip?r=&ts=1525544602&use_mirror=excellmedia'
    Invoke-WebRequest -Uri $uri -OutFile $console2zip†-UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
    Expand-Archive $console2zip
    echo "Saved : Console2"
} else {
    echo "Skip : Console2"
 }

#e. move console2 config file to appropriate location


#f. download kdb executable?
#maybe just a try-catch to make sure q is installed

#g. set environment variables : qpath and sme other path
# again a try-catch to make sure these variables are set


#start console2


function DownloadFilesFromGithub {
Param(
    [string]$Owner,
    [string]$Repository,
    [string]$Path,
    [string]$DestinationPath
    )

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"
    $wr = Invoke-WebRequest -Uri $($baseuri+$args)
    $objects = $wr.Content | ConvertFrom-Json
    $files = $objects | where {$_.type -eq "file"} | Select -exp download_url
    $directories = $objects | where {$_.type -eq "dir"}
    
    $directories | ForEach-Object { 
        DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath+$_.name)
    }

    
    if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
        } catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
        try {
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
            "Grabbed '$($file)' to '$fileDestination'"
        } catch {
            throw "Unable to download '$($file.path)'"
        }
    }

}