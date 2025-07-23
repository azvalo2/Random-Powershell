# Parametre interaktívne
$operation = Read-Host "Akú operáciu chceš? (+, -, *, /) [default: -]"
if ($operation -notin '+','-','*','/') { $operation = '-' }

$digitCountInput = Read-Host "Koľko číslic? (2, 3 alebo 4) [default: 2]"
if ($digitCountInput -in '2','3','4') { $digitCount = [int]$digitCountInput } else { $digitCount = 2 }

# Konštanty
$exampleCount = 48
$columns = 8
$rows = 6

$min = [math]::Pow(10, $digitCount - 1)
$max = [math]::Pow(10, $digitCount) - 1

$rand = New-Object System.Random

# Generovanie príkladov
$examples = @()
while ($examples.Count -lt $exampleCount) {
    switch ($operation) {
        '+' {
            $a = $rand.Next($min, $max + 1)
            $b = $rand.Next($min, $max + 1)
            # zabezpečiť prenos
            if ((($a % 10) + ($b % 10)) -lt 10) { continue }
        }
        '-' {
            $a = $rand.Next($min, $max + 1)
            $b = $rand.Next($min, $max + 1)
            if ($a -lt $b) { $temp = $a; $a = $b; $b = $temp }
            if ((($a % 10) - ($b % 10)) -ge 0) { continue }
        }
        '*' {
            # aby výsledky boli vhodné na ručné počítanie pod sebou
            $a = $rand.Next(2 * [math]::Pow(10, $digitCount - 2), $max + 1)
            $b = $rand.Next(2, 10)
        }
        '/' {
            # generovať deliteľný príklad
            $b = $rand.Next(2, 10)
            $c = $rand.Next(2 * [math]::Pow(10, $digitCount - 2), $max / $b)
            $a = $b * $c
        }
    }

    $examples += [PSCustomObject]@{A = $a; B = $b; Op = $operation}
}

function Format-Example {
    param($ex)
    $width = $digitCount + 3

    $line1 = $ex.A.ToString().PadLeft($width)
    $line2 = $ex.Op + " " + $ex.B.ToString().PadLeft($width - 2)
    $line3 = "¯" * $width
    $line4 = " " * $width
    return @($line1, $line2, $line3, $line4)
}

# Vytvorenie výstupu
$outputLines = New-Object System.Collections.Generic.List[string]

for ($row = 0; $row -lt $rows; $row++) {
    for ($lineIdx = 0; $lineIdx -lt 4; $lineIdx++) {
        $line = ""
        for ($col = 0; $col -lt $columns; $col++) {
            $index = $row + $col * $rows
            $exLines = Format-Example $examples[$index]
            $line += $exLines[$lineIdx] + "  "
        }
        $outputLines.Add($line)
    }
    $outputLines.Add("")
}

# Nadpis prispôsobený podľa operácie
$opName = switch ($operation) {
    '+' { "Plus" }
    '-' { "Mínus" }
    '*' { "Násobenie" }
    '/' { "Delenie" }
}
$title = "Superschopnosť: $opName pod sebou"

$footer = "Najprv počítaj čo najrýchlejšie, potom si výsledky dôkladne skontroluj.`nSprávne vypočítaných: _____ príkladov."

# Generovanie HTML
$desktop = [Environment]::GetFolderPath("Desktop")
$timestamp = Get-Date -Format "ddMMyyyy-HHmmss"
$file = Join-Path $desktop "priklady_$timestamp.html"

$html = @"
<html>
<head>
    <meta charset='UTF-8'>
    <title>Príklady - Superschopnosť</title>
    <style>
        body { font-family: Consolas, monospace; margin: 40px; white-space: pre; }
        .title { font-weight: bold; font-size: 18px; margin-bottom: 20px; }
        .footer { margin-top: 20px; font-size: 14px; }
        .example-block { line-height: 1.1em; }
    </style>
</head>
<body>
<div class='title'>$title</div>
<div class='example-block'>
"@

foreach ($line in $outputLines) {
    $html += $line + "`n"
}

$html += @"
</div>
<div class='footer'>$footer</div>
</body>
</html>
"@

$html | Out-File -Encoding UTF8 $file

Write-Host "Hotovo! Súbor uložený na plochu: $file"
