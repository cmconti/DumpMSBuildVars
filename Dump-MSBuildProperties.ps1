
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

& "$MSBuildEXE" /v:diagnostic /fl /p:Configuration=Debug /p:Platform=Win32 "$PSScriptRoot\CPPHelloWorld\CPPHelloWorld.vcxproj" /t:Clean | out-null
& "$MSBuildEXE" /v:diagnostic /fl /p:Configuration=Debug /p:Platform=Win32 "$PSScriptRoot\CPPHelloWorld\CPPHelloWorld.vcxproj" /t:Build | Set-Content vcxproj-Build.txt
& "$MSBuildEXE" /v:diagnostic /fl /p:Configuration=Debug /p:Platform=Win32 "$PSScriptRoot\CPPHelloWorld\CPPHelloWorld.vcxproj" /pp:Flat.vcxproj | Set-Content vcxproj.txt

$build = Get-Content .\vcxproj-Build.txt
$commandline = ($build | Select-String '^Command line arguments = "(.*)"$').Matches[0].Groups[1].Value
$envvar = (([regex]::Match($build -join 'qweqwe', 'Environment at start of build:(.*?)qweqweqweqweProcess = ')).Groups[1].Value).Replace('qweqwe',"`r`n")
$reassign = (($build | Select-String '^Property reassignment: (.*)').Matches | ForEach-Object{$_.Groups[1].Value})

""
"----------------VCXPROJ----------------"
$commandline
"---Env Vars---"
$envvar
"---Reassigned Vars---"
$reassign
"---Prop Groups---"
.\Parse-PropertyGroup .\Flat.vcxproj

& "$MSBuildEXE" /v:diagnostic /fl /p:Configuration=Debug /p:Platform=AnyCPU "$PSScriptRoot\CSHelloWorld\CSHelloWorld.csproj" /t:Clean | out-null
& "$MSBuildEXE" /v:diagnostic /fl /p:Configuration=Debug /p:Platform=AnyCPU "$PSScriptRoot\CSHelloWorld\CSHelloWorld.csproj" /t:Build | Set-Content csproj-Build.txt
& "$MSBuildEXE" /v:diagnostic /fl /p:Configuration=Debug /p:Platform=AnyCPU "$PSScriptRoot\CSHelloWorld\CSHelloWorld.csproj" /pp:Flat.csproj | Set-Content csproj.txt

$build = Get-Content .\csproj-Build.txt
$commandline = ($build | Select-String '^Command line arguments = "(.*)"$').Matches[0].Groups[1].Value
$envvar = (([regex]::Match($build -join 'qweqwe', 'Environment at start of build:(.*?)qweqweqweqweProcess = ')).Groups[1].Value).Replace('qweqwe',"`r`n")
$reassign = (($build | Select-String '^Property reassignment: (.*)').Matches | ForEach-Object{$_.Groups[1].Value})

""
"----------------CSPROJ----------------"
$commandline
"---Env Vars---"
$envvar
"---Reassigned Vars---"
$reassign
"---Prop Groups---"
.\Parse-PropertyGroup .\Flat.csproj

