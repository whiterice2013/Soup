# a.ps1 - The Spark of Life (Civilization Edition)
$SoupDir = "G:\Soup"
# Added 'w' and 'v' so they can start using the vault immediately
$chars = @('>', '<', '+', '-', '[', ']', 'k', 'a', 'p')

if (!(Test-Path $SoupDir)) { New-Item -ItemType Directory $SoupDir }

# Clearing old files to prevent ID collisions
Get-ChildItem $SoupDir -Filter "*.ps1" | Remove-Item -Force

for ($i = 1; $i -le 1000; $i++) {
    # Generate random DNA (Length 30-60 for better starting variety)
    $dnaLength = Get-Random -Min 5 -Max 61
    $DNA = -join (1..$dnaLength | ForEach-Object { $chars | Get-Random })
    
    # Save with numeric filename
    $DNA | Out-File "$SoupDir\$($i).ps1" -Encoding ascii
}

Write-Host "--- 1000 DNA Packages Seeded ---" -ForegroundColor Green
Write-Host "The Vault and Shared archives are ready for interaction." -ForegroundColor Cyan