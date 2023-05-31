$boatAttackUnityVersion = "2020.3.23f1"

$boatAttackScenes = @(
    "Assets/scenes/demo_island.unity"
    "Assets/scenes/main_menu.unity"
    "Assets/scenes/static_island.unity"
)

$spaceshipDemoScenes = @(
    "Assets/Scenes/Boot.unity"
    "Assets/Scenes/MainMenu/MainMenu.unity"
    "Assets/Scenes/Spaceship/Spaceship.unity"
)


function Invoke-Build-Setup($ProjectPath, $Scenes, $Linux) {

    Foreach ($scene in $Scenes) {
        if (-not (Test-Path "$ProjectPath/$scene")) {
            Throw "Didn't find $scene"
        }
    }

    Remove-Item -Path "$ProjectPath/Build" -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path "$ProjectPath/Build" -ItemType Directory -Force | Out-Null
    Copy-Item "Builder.cs" "$ProjectPath/Assets/Scripts/Editor/Builder.cs" -Force

    $replace = 'com.unity.toolchain.win-x86_64-linux-x86_64','com.unity.toolchain.linux-x86_64'
    if ($Linux == $false) {
        $replace = 'com.unity.toolchain.linux-x86_64','com.unity.toolchain.win-x86_64-linux-x86_64'
    }
    
    (Get-Content -path "$ProjectPath/Packages/manifest.json" -Raw) -replace $replace | Set-Content -Path "$ProjectPath/Packages/manifest.json"
    if (Test-Path "$ProjectPath/Packages/packages-lock.json") {
        (Get-Content -path "$ProjectPath/Packages/packages-lock.json" -Raw) -replace $replace | Set-Content -Path "$ProjectPath/Packages/packages-lock.json"
    }
}