param ([parameter(Mandatory=$true)][string]$verb)

Set-Strictmode -version latest
$ErrorActionPreference = "Stop"

. ./license.ps1
. ./build_setup.ps1

if (-Not (Test-Path 'env:UNITY_USERNAME')) { Throw }
if (-Not (Test-Path 'env:UNITY_PASSWORD')) { Throw }
if (-Not (Test-Path 'env:UNITY_SERIAL')) { Throw }

function Invoke-Build($ProjectPath, $UnityVersion, $Platform, $Scenes) {
    Write-Host "Building $ProjectPath with $UnityVersion ($verb)"

    Invoke-Build-Setup -ProjectPath $ProjectPath -Scenes $Scenes -Linux $true

    $Scenes | Set-Content -Path "$ProjectPath/SceneList"

    $timing = Measure-Command {
        docker run --rm `
        --name ${ProjectPath}-builder `
        --hostname ${env:COMPUTERNAME}-Docker `
        -v ${PWD}/${ProjectPath}:/project `
        -v ${PWD}/${ProjectPath}/Build:/build `
        unityci/editor:ubuntu-$UnityVersion-1.0 `
        unity-editor `
        -username "$env:UNITY_USERNAME" -password "$env:UNITY_PASSWORD" -serial "$env:UNITY_SERIAL" `
        -buildTarget $Platform -projectPath /project `
        -logFile /dev/stdout -nographics `
        -executeMethod Builder.BuildProject -quit | Out-Default | Tee-Object -FilePath "${ProjectPath}/Build/Build.log"
    }

    #   Docker will leave files as root

    sudo chown -R $env:USER:$env:USER $ProjectPath

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
