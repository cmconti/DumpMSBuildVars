<#
.Description
Parse property group values from flat project file
https://stackoverflow.com/questions/4548618/list-all-defined-msbuild-variables-equivalent-to-set
#>
param(
[Parameter(Mandatory = $True)][Alias('f')][string] $file )

[xml]$proj = Get-Content $file

[xml]$proj = Get-Content .\Flat.vcxproj
$ns = @{vs = 'http://schemas.microsoft.com/developer/msbuild/2003'; }

$propertygroups = select-xml -xpath "//vs:PropertyGroup" $proj -Namespace $ns

#$propertygroups | %{$_.Node}
$propertygroups | ForEach-Object{
    'Group'
    if ($_.Node.HasAttributes) {
        '  Attributes'
        ($_.Node.Attributes | ForEach-Object{
            "    $($_.Name)=$($_.Value)"
        })
    }
    ($_.Node.ChildNodes | ForEach-Object{
        "  $($_.Name)=$($_.InnerText)"
        if ($_.HasAttributes) {
            #'  Attributes'
            ($_.Attributes | ForEach-Object{
                "    $($_.Name)=$($_.Value)"
            })
        }
    })
}
