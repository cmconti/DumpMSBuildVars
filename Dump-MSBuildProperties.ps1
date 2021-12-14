
$VSEnterprise = $false

if (Test-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\") {
    # Call Enterprise version of Visual Studio
    $VSRootDir = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
    $VSEnterprise = $true
}
else {
    # Call Professional version of Visual Studio
    $VSRootDir = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional"
}

$MSBuildEXE = "$VSRootDir\MSBuild\Current\Bin\MSBuild.exe"

# based on https://stackoverflow.com/questions/4548618/list-all-defined-msbuild-variables-equivalent-to-set

& "$MSBuildEXE" /v:detailed /fl /p:Configuration=Debug /p:Platform=Win32 "$PSScriptRoot\CPPHelloWorld\CPPHelloWorld.vcxproj" /t:Clean | out-null
& "$MSBuildEXE" /v:detailed /fl /p:Configuration=Debug /p:Platform=Win32 "$PSScriptRoot\CPPHelloWorld\CPPHelloWorld.vcxproj" /t:Build | sc vcxproj-Build.txt
& "$MSBuildEXE" /v:detailed /fl /p:Configuration=Debug /p:Platform=Win32 "$PSScriptRoot\CPPHelloWorld\CPPHelloWorld.vcxproj" /pp:Flat.vcxproj | sc vcxproj.txt

$build = gc .\vcxproj-Build.txt
$commandline = ($build | sls '^Command line arguments = "(.*)"$').Matches[0].Groups[1].Value
$envvar = (([regex]::Match($build, 'VCEnd(.*?)Done')).Groups[1].Value).Replace('   ',"`r`n")
$reassign = (($build | sls '^Property reassignment: (.*)').Matches | %{$_.Groups[1].Value})

""
"----------------VCXPROJ----------------"
$commandline
$envvar
$reassign
"---Prop Groups---"
.\Parse-PropertyGroup .\Flat.vcxproj

& "$MSBuildEXE" /v:detailed /fl /p:Configuration=Debug /p:Platform=AnyCPU "$PSScriptRoot\CSHelloWorld\CSHelloWorld.csproj" /t:Clean | out-null
& "$MSBuildEXE" /v:detailed /fl /p:Configuration=Debug /p:Platform=AnyCPU "$PSScriptRoot\CSHelloWorld\CSHelloWorld.csproj" /t:Build | sc csproj-Build.txt
& "$MSBuildEXE" /v:detailed /fl /p:Configuration=Debug /p:Platform=AnyCPU "$PSScriptRoot\CSHelloWorld\CSHelloWorld.csproj" /pp:Flat.csproj | sc csproj.txt

$build = gc .\csproj-Build.txt
$commandline = ($build | sls '^Command line arguments = "(.*)"$').Matches[0].Groups[1].Value
$envvar = (([regex]::Match($build, 'VCEnd(.*?)Done')).Groups[1].Value).Replace('   ',"`r`n")
$reassign = (($build | sls '^Property reassignment: (.*)').Matches | %{$_.Groups[1].Value})

""
"----------------CSPROJ----------------"
$commandline
$envvar
$reassign
"---Prop Groups---"
.\Parse-PropertyGroup .\Flat.csproj

