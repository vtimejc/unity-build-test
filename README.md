## Unity Build Test

# What this is

This is a set of projects (some of Unity's own sample projects) that we can build easily and repeatedly to test the efficiency of build infrastructure.

This makes extensive use of [Game CI's](https://game.ci/) Docker images of Unity.

# Setup

You will need:
* A minimum of 200GB of free drive space.
* A modern LFS enabled `git`.
* [Docker](https://docs.docker.com/engine/install/)
* [Powershell (pwsh)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.3) 

To set up the tests

`git clone https://github.com/vtimejc/unity-build-test --recurse-submodules`

This will take about half an hour

`pwsh pull.ps1`

This will take about 10 minutes


# Running Tests

To run the tests:

(Assuming you are running on Linux or WSL)
* pwsh clean.ps1
* pwsh build_linux.ps1

(Assuming you are running on Windows with Docker in Windows Containers mode.)
* pwsh clean.ps1
* pwsh build_windows.ps1
 
The tests take about an hour in total
