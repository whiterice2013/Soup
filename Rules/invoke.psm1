function Invoke-BF($code, $life) {
    # 1. Properly handle the input (ensure it's a string, not an object)
    $rawCode = [string]$code
    # 2. Synchronized Regex with supported instructions (k, p, a)
    $allowed = '><\+\-\[\]kpa'
    $clean = $rawCode -replace "[^$allowed]", ''
    
    # Ensure SoupDir is available for k, p, a operations
    $targetDir = if ($null -ne $Global:SoupDir) { $Global:SoupDir } else { "G:\Soup" }

    # Emergency exit if file no longer exists or code is empty
    if (!(Test-Path $life.FullName)) {
        return @{ ActionCount = 0; Kill = $life; Log = "Target missing" }
    }
    if ($clean.Length -eq 0) {
        $kill += $life.FullName
        return @{ ActionCount = 0; FixedCode = ""; Log = "Empty DNA"; Kill = $kill; Steps = 0 }
        continue
    }

    $tape = New-Object Byte[] 300; $ptr = 0; $pc = 0; $out = ""; $act = 0; $energy = 100; $kill = @()
    $files = Get-ChildItem $targetDir -Filter "*.ps1"

    # Structural Fix for unmatched loops
    $open = ([regex]::Matches($clean, "\[")).Count
    $close = ([regex]::Matches($clean, "\]")).Count
    if ($open -gt $close) { 
        $clean += "]" * ($open - $close)
    }

    try {
        while ($pc -lt $clean.Length ) {
            # 1. Pay the tax
            $energy -= 0.05

            # write-host "Energy: $energy | PC: $pc | Ptr: $ptr | Tape[Ptr]: $($tape[$ptr]) | Act: $act | file: $life.Name"  -ForegroundColor Yellow

            # 2. Instant Death check
            if ($energy -le 0) {
                $kill += $life.FullName
                return @{ ActionCount = $act; FixedCode = $clean; Log = "$out[Starved]"; Kill = $kill }
            }
            
            

            switch ($clean[$pc]) {
                '>' { 
                    $ptr = ($ptr + 1) % 300
                    $energy -= 0.1
                    $act++
                }
                '<' { 
                    $ptr = if ($ptr -eq 0) { 299 } else { $ptr - 1 }
                    $energy -= 0.1
                    $act++
                }
                '+' { 
                    $tape[$ptr] = ($tape[$ptr] + 1) % 256
                    $energy -= 0.1
                    $act++
                }
                '-' { 
                    $tape[$ptr] = if ($tape[$ptr] -eq 0) { 255 } else { $tape[$ptr] - 1 }
                    $energy -= 0.1
                    $act++
                }
                '[' { 
                    if ($tape[$ptr] -eq 0) { 
                        $energy -= 5
                        $d = 1
                        while ($d -gt 0 -and $pc -lt $clean.Length-1) { 
                            $pc++
                            if ($clean[$pc] -eq '['){$d++} elseif ($clean[$pc] -eq ']'){$d--} 
                        } 
                    }
                }
                ']' { 
                    if ($tape[$ptr] -ne 0) { 
                        $energy -= 5
                        $d = 1
                        while ($d -gt 0 -and $pc -gt 0) { 
                            $pc--
                            if ($clean[$pc] -eq ']'){$d++} elseif ($clean[$pc] -eq '['){$d--} 
                        } 
                    }
                }
                
                # k: Predation - Selects a victim from the soup based on the current tape value
                'k' { 
                    if ($files.Count -gt 0) {
                        $target = $files[$tape[$ptr] % $files.Count]
                        if ($target -and (Test-Path $target.FullName)) {
                            $kill += $target.FullName
                            $out += "[Killed $($target.BaseName)]"; $act++
                            $energy += 50 # This will make every one die
                            # Update local list to reflect the kill without actually removing the file (since it will be removed at the end of the loop)
                            $files = $files | Where-Object { $_.FullName -ne $target.FullName }
                        }
                    }
                }
                
                # p: Reproduction - Creates a new entity using DNA stored in the tape
                'p' { 
                    $dnaString = ""
                    $allowedList = $allowed.ToCharArray()
                    # Look at the tape from the pointer to the end
                    for ($i = ($ptr + 1); $i -lt 300; $i++) {
                        $val = $tape[$i]
                        # Skip empty cells
                        if ($val -eq 0) { continue }
                        # Convert the number to a character
                        $char = $allowedList[$val % $allowedList.Count]
                        # Check if the character is in your allowed list
                        if ($allowed.Contains($char)) {
                            $dnaString += $char
                        }
                    }
                    if ($dnaString) {
                        $max = $files[$files.Count - 1]
                        $name = [int]$max.BaseName + 1
                        $name.ToString()
                        $dnaString | Out-File (Join-Path $targetDir "$name.ps1") -Encoding ascii
                        $out += "[Spawned $name]"; $act++
                        $energy -= 80
                    }
                }

                # a: Horizontal Gene Transfer - Absorbs DNA from another entity in the soup
                'a' {
                    if ($files.Count -gt 0) {
                        $index = $tape[$ptr] % $files.Count
                        $target = $files[$index]
                        if ($target -and $target.Name -ne $life.Name) {
                            $clean += (Get-Content $target.FullName -Raw).Trim()
                            $out += "[Absorbed $($target.BaseName)]"; $act++
                            $kill += $target.FullName
                        $energy -= 10
                        }
                    }
                }
            }
            $pc++
        }
        return @{ ActionCount = $act; FixedCode = $clean; Log = $out; Kill = $kill }
    } catch { return @{ ActionCount = 0; Error = $true } }
}