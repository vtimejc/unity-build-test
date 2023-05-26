function Invoke-Build($ProjectPath, $UnityVersion, $Platform, $Scenes) {
    Write-Host "Building $ProjectPath with $UnityVersion"

    Remove-Item "$ProjectPath/Build" -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path "$ProjectPath/Build" -ErrorAction SilentlyContinue

docker run --rm `
  --name ${env:JOB_NAME} `
  --hostname ${env:COMPUTERNAME}-DockerContainer `
  -e UNITY_USERNAME `
  -e UNITY_PASSWORD `
  -e UNITY_SERIAL `
  -e WORKSPACE_ROOT=${PWD} `
  -v ${PWD}:/project `
  -v ${PWD}/Build:/build `
  unityci/editor:${env:UNITY_IMAGE} `
  /bin/bash -c "unity-editor -buildTarget $Platform -projectPath /project -nographics -executeMethod Builder.BuildProject -quit"
}

$boatAttackScenes = @(
    "Assets/scenes/demo_island.unity"
    "Assets/scenes/main_menu.unity"
    "Assets/Scenes/static_island.unity"
)

Invoke-Build -ProjectPath "boat-attack" -UnityVersion "2020.3.23f1-android" -Platform "Android" -Scenes $boatAttackScenes