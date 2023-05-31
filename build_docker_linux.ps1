param ([parameter(Mandatory=$true)][string]$verb)

Set-strictmode -version latest
$ErrorActionPreference = "Stop"


. ./license.ps1

if (-Not (Test-Path 'env:UNITY_USERNAME')) { Throw }
if (-Not (Test-Path 'env:UNITY_PASSWORD')) { Throw }
if (-Not (Test-Path 'env:UNITY_SERIAL')) { Throw }

function Invoke-Build($ProjectPath, $UnityVersion, $Platform, $Scenes) {
    Write-Host "Building $ProjectPath with $UnityVersion ($verb)"

    Foreach ($scene IN $Scenes) {
        if (-Not (Test-Path "$ProjectPath/$scene")) {
            Throw "Didn't find $scene"
        }
    }

    Remove-Item -Path "$ProjectPath/Build" -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path "$ProjectPath/Build" -ItemType Directory -Force | Out-Null
    Copy-Item "Builder.cs" "$ProjectPath/Assets/Scripts/Editor/Builder.cs" -Force

    (Get-Content -path "$ProjectPath/Packages/manifest.json" -Raw) -replace 'com.unity.toolchain.win-x86_64-linux-x86_64','com.unity.toolchain.linux-x86_64' | Set-Content -Path "$ProjectPath/Packages/manifest.json"
    (Get-Content -path "$ProjectPath/Packages/packages-lock.json" -Raw) -replace 'com.unity.toolchain.win-x86_64-linux-x86_64','com.unity.toolchain.linux-x86_64' | Set-Content -Path "$ProjectPath/Packages/packages-lock.json"

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

    $numFiles = Get-ChildItem "${ProjectPath}/Build" -Recurse -File | Measure-Object | ForEach-Object { $_.Count }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

    Write-Host "Build took $timing in $verb mode"

    $result = @"
Building $ProjectPath took $timing in $verb mode
Build generated $numFiles files
"@
    
    $result | Set-Content -Path "${timestamp}_${ProjectPath}-${verb}-files.txt"
}

# $boatAttackScenes = @(
#     "Assets/scenes/demo_island.unity"
#     "Assets/scenes/main_menu.unity"
#     "Assets/scenes/static_island.unity"
# )

# Invoke-Build -ProjectPath "boat-attack" -UnityVersion "2020.3.23f1-android" -Platform "Android" -Scenes $boatAttackScenes

$spaceshipDemoScenes = @(
    "Assets/Scenes/Boot.unity"
    "Assets/Scenes/MainMenu/MainMenu.unity"
    "Assets/Scenes/Spaceship/Spaceship.unity"
)

Invoke-Build -ProjectPath "spaceship-demo" -UnityVersion "2022.2.6f1-windows-mono" -Platform "Win64" -Scenes $spaceshipDemoScenes

# $megacitySampleScenes = @(
#     "Assets/Scenes/MegaCity.unity"
# )

# Invoke-Build -ProjectPath "megacity-sample" -UnityVersion "2022.2.12f1-windows-mono" -Platform "Win64" -Scenes $megacitySampleScenes
