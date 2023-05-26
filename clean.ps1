function Invoke-Clean($ProjectPath) {
    Write-Host "Cleaning $ProjectPath"
    Remove-Item "$ProjectPath/Library" -Recurse -Force -ErrorAction SilentlyContinue
}

Invoke-Clean "boat-attack"
Invoke-Clean "megacity-sample"
Invoke-Clean "spaceship-demo"