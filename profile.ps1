param (
    [parameter(Mandatory=$true)]
    [ValidateSet("docker_linux", "windows")]
    [string]
    $platform
)

$script=".\build_$platform.ps1"

.\clean.ps1
& $script clean
& $script rebuild