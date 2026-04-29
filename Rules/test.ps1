Import-Module "G:rules\invoke.psm1" -Force

$files = Get-ChildItem "G:\Soup" -Filter "*.ps1"
$f = $files[1]
$dna = [string](Get-Content $f.FullName -Raw)

$res = Invoke-BF $dna $f

# 1. Survival Check: If Invoke-BF deleted the file, skip to the next one
if (!(Test-Path $f.FullName)) { 
    Write-Host "[-] $($f.Name) starved." -ForegroundColor Gray
    continue 
}

# 2. SAVE THE EVOLUTION (Critical!)
# Write the fixed/absorbed DNA back to the file so changes persist
$res.FixedCode | Out-File $f.FullName -Encoding ascii

# 3. Formatting for the Terminal
$name = $f.BaseName.ToString().PadRight(6)
$len  = $res.FixedCode.Length.ToString().PadRight(6)
$acts = $res.ActionCount.ToString().PadRight(6)

# 4. Success Output
Write-Host "[!] $name | DNA: $len | Acts: $acts | does: $($res.Log)" -ForegroundColor Green