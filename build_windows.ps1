param ([parameter(Mandatory=$true)][string]$verb)

Set-strictmode -version latest
$ErrorActionPreference = "Stop"

. build_setup.ps1

function Invoke-Build($ProjectPath, $UnityVersion, $Platform, $Scenes) {
    Write-Host "Building $ProjectPath with $UnityVersion ($verb)"

    if (!Test-Path "C:\Program Files\Unity\Hub\Editor\$UnityVersion\Editor\Unity.exe") {
        Write-Host "Unity version $UnityVersion not found"
        return
    }

    Invoke-Build-Setup -ProjectPath $ProjectPath -Scenes $Scenes -Linux $true

    $Scenes | Set-Content -Path "$ProjectPath/SceneList"

    $timing = Measure-Command {
        "C:\Program Files\Unity\Hub\Editor\$UnityVersion\Editor\Unity.exe"
        -buildTarget $Platform -projectPath ${ProjectPath} `
        -executeMethod Builder.BuildProject -quit | Out-Default | Tee-Object -FilePath "${ProjectPath}/Build/Build.log"
    }

    $numFiles = Get-ChildItem "${ProjectPath}/Build" -Recurse -File | Measure-Object | ForEach-Object { $_.Count }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

    Write-Host "Build took $timing in $verb mode"

    $result = @"
Building $ProjectPath took $timing in $verb mode
Build generated $numFiles files
"@
    
    $result | Set-Content -Path "${timestamp}_${ProjectPath}-${Platform}-${verb}-files.txt"
}

Invoke-Build -ProjectPath "boat-attack" -UnityVersion "$boatAttackUnityVersion-android" -Platform "Android" -Scenes $boatAttackScenes

Invoke-Build -ProjectPath "boat-attack" -UnityVersion "$boatAttackUnityVersion-ios" -Platform "iOS" -Scenes $boatAttackScenes

Invoke-Build -ProjectPath "spaceship-demo" -UnityVersion "$spaceshipDemoUnityVersion-windows-mono" -Platform "Win64" -Scenes $spaceshipDemoScenes
