$ErrorActionPreference = "Stop"

try { Install-Module pester -force -Confirm:$false -Scope CurrentUser -SkipPublisherCheck } Catch {}
try {
    $ECode = 0

    Set-Location $ENV:GITHUB_WORKSPACE\Test\
    Import-Module Pester -Force -MinimumVersion "4.8.1"

    $outputfolder = "$PSScriptRoot\PesterOutput\"
    New-Item $outputfolder -Force -ItemType Directory
    $results = Invoke-Pester -Script "$PSScriptRoot\Service-Path-Enumeration-TestCases.ps1" -OutputFormat NUnitXml `
                            -OutputFile "$OutputFolder\Services-And-Software-Verification.xml" -PassThru
} catch {
    Write-Host "Something failed during script execution. Error: $_"
} Finally {
    if ($results.FailedCount -gt 0) {
        Write-Host "Tests failed..."

        Foreach ($LogPath in @("$PSScriptRoot\ScriptOutput\Service_Log.txt", "$PSScriptRoot\ScriptOutput\Software_Log.txt")){
            Write-Host ">>> Log file '$LogPath' content:"
            Get-Content $LogPath
        }
        $ECode = 2
    } elseif ($results.TotalCount -eq 0){
        Write-Host "Tests not started..."
        $ECode = 3
    }
}

Exit $ECode