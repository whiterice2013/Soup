# loop.ps1 - The Civilization Simulation
$Global:SoupDir = "G:\Soup"
$RulesDir = "G:\Rules"
$BFChars = @('>', '<', '+', '-', '[', ']', 'k', 'p', 'a') 
Import-Module "$RulesDir\invoke.psm1" -Force

while ($true) {
    $files = Get-ChildItem "$SoupDir" -Filter "*.ps1"
    if ($files.Count -eq 0) { 
        & "$RulesDir\a.ps1"; 
        Write-Host "--- 1000 DNA Packages Seeded ---" -ForegroundColor Green
        continue 
    }

    foreach ($f in $files) {
        if (!(Test-Path $f.FullName)) { continue }
        $dna = [string](Get-Content $f.FullName -Raw)
        if ([string]::IsNullOrEmpty($dna)) { $dna = "" }
        
        # Stable Mutation Logic
        $mRate = 0.005 # 0.5% chance
        $SB = New-Object System.Text.StringBuilder # Fast memory handling

        foreach ($char in $dna.ToCharArray()) {
            if (((Get-Random -Max 1000) / 1000) -lt $mRate) {
                $roll = (Get-Random -Max 1000) / 1000
                
                if ($roll -lt 0.05) { 
                    # RARE: Insert - adds a random char WITHOUT deleting the current one
                    [void]$SB.Append($char)
                    [void]$SB.Append(($BFChars | Get-Random))
                } elseif ($roll -lt 0.10) { 
                    continue 
                } else { 
                    [void]$SB.Append(($BFChars | Get-Random))
                }
            } else {
                [void]$SB.Append($char)
            }
        }
        $mutated = $SB.ToString()
        $res = Invoke-BF $mutated $f

        # 1. Survival Check: If Invoke-BF deleted the file, skip to the next one
        if ($res.Error -eq $true) { 
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
    }

    Start-Sleep -Milliseconds 100

}
