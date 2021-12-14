# DumpMSBuildVars


Environment:  VS2019



Dump the variables that are used by MSBUILD for a C# and C++ project.

The variables used are impacted by environment variables, msbuild command line args, order of evaluation, etc.,  and so the list can never be truly complete.

This project uses near bare-bones C++ and C# hello world style projects as a starting point for evaluating the variables that come into play.



**Note:**  If you are interested in a particular variable, the simplest way to track its value is to add a property group at the top of your csproj/vcxproj file before any other property groups or imports, and then compile with diagnostic verbosity.  MSBuild will log any time an existing variable is changed, including what the new value, old value, and location of change are.

e.g.

```xml
<Project ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <MyFunkyVar></MyFunkyVar>
  </PropertyGroup>
  ... rest of existing file
```

If the value is set to something else during the build, the diagnostic output will contain a line similar to:

`Property reassignment: $(MyFunkyVar)="newFunkyVal" (previous value: "") at C:\repodir\DumpMSBuildVars\CSHelloWorld\CSHelloWorld.csproj (32,5)`



If you're still looking for a general dump-everything-you-can-find, then try this project.

On a machine with VS2019 installed in the default directory, and the working directory in the cloned repo, run:
`powershell -File .\Dump-MSBuildProperties.ps1 > variables.txt`


the variables.txt content will be formatted like this:

```txt

----------------VCXPROJ----------------
<msbuild command line for the C++ project>

<list of environment variables from msbuild diagnostic output>

<list of any properties that were reassigned during the build>

<list of all the property groups that can be processed in the C++ project>


----------------CSPROJ----------------
<msbuild command line for the C# project>

<list of environment variables from msbuild diagnostic output>

<list of any properties that were reassigned during the build>

<list of all the property groups that can be processed in the C# project>
```



The property groups are listed in the order they would be evaluated during the build, and include any attributes on the group or property (particularly conditions)

for example, one group in the output on my machine:

```txt
Group
  Attributes
    Condition='$(WindowsSDKInstalled)' == '' and '$(WindowsSDK_UAP_Support)' == '' and '$(WindowsSDK_Desktop_Support)' == ''
  WindowsSDKInstalled=false
  WindowsSDK_UAP_Support=false
  WindowsSDK_Desktop_Support=false
  WindowsSDKInstalled=true
    Condition=Exists('$(WindowsSdkDir)\DesignTime\CommonConfiguration\Neutral\UAP\$(TargetPlatformVersion)\UAP.props')
  #comment= Currently we assume that UWP SDK portion is installed when UAP.props is found
  WindowsSDK_UAP_Support= $(WindowsSDKInstalled)
  WindowsSDK_Desktop_Support=true
    Condition=Exists('$(WindowsSdkDir)\Include\$(TargetPlatformVersion)\shared\sdkddkver.h') and
                                             Exists('$(WindowsSdkDir)\Lib\$(TargetPlatformVersion)\um\$(PlatformShortName)\gdi32.lib')
```

The group itself has a condition for evaluation, and several of the properties have their own conditions.  Also note that comments inside the property group are currently displayed.

This script does not:

- Try to resolve the values of variables at any point
- Show the value of a variable at a given point in the build process
- Take into account any tasks which manipulate variables outside of the flattened project file
- Handle property groups with nested nodes
- Win you any friends, family, or fortune (YMMV)



How does it do it?

Compiles the vcxproj/csproj with diagnostic output logged to a file which is parsed for the command line and environment variables

Creates a flattened project file (msbuild.exe ... /pp:Flat.csproj) and then parses the flattened project file looking for PropertyGroup nodes.



Credit for idea to [Filip Skakun's answer](https://stackoverflow.com/a/35027951) at

https://stackoverflow.com/questions/4548618/list-all-defined-msbuild-variables-equivalent-to-set
