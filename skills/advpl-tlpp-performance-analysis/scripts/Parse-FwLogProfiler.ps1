<#
.SYNOPSIS
    Agrega um log do FWLogProfiler (Protheus) em tabelas de hotspot, sem carregar
    o log inteiro no contexto do agente.

.DESCRIPTION
    Os logs do FWLogProfiler tem apenas dois tipos de linha uteis:

        CALL    <FUNC>(<FONTE>)        C <chamadas> T <tempo_inclusivo> M <maior_chamada>
        -- FROM <CHAMADOR> (<FONTE>) (<linha>)  C <chamadas> T <tempo> M <maior>

    As linhas "-- FROM" que seguem um "CALL F" decompoem o T de F por *call site*.
    Logo:
      - somar as linhas "-- FROM F" espalhadas por TODOS os blocos CALL da o
        detalhamento dos CALLEES de F (onde F gasta o tempo dela);
      - as linhas "-- FROM x" dentro do bloco CALL F dao os CALLERS de F.

    T e tempo INCLUSIVO (funcao + descendentes). Nunca some T de funcoes de
    niveis diferentes: da mais de 100%.

.PARAMETER Path
    Caminho do arquivo .log do FWLogProfiler.

.PARAMETER Top
    Quantas linhas exibir nos rankings. Default 25.

.PARAMETER Function
    Funcao/metodo foco (case-insensitive, aceita nome parcial). Exibe callers e
    callees dessa funcao, com % sobre o T dela.

.PARAMETER Root
    Funcao usada como 100% do ranking global. Use a raiz da rotina medida
    (ex.: REPORTPRINT, GETDATA, MYALIASTODATA). Sem isso o script usa o maior T
    do log como referencia e avisa. NUNCA use T.Timer como 100%: ele inclui
    tempo ocioso (usuario no wizard).

.PARAMETER Compare
    Caminho de um segundo log. Gera tabela lado a lado (A vs B) por funcao.
    Use para legado x Smart View, ou antes x depois da correcao.

.PARAMETER MinSeconds
    Descarta funcoes com T abaixo desse valor nos rankings. Default 0.1.

.PARAMETER Csv
    Grava o ranking global em CSV no caminho informado.

.EXAMPLE
    .\Parse-FwLogProfiler.ps1 -Path .\smartview.log -Root MYPROCESSDATA -Top 20

.EXAMPLE
    .\Parse-FwLogProfiler.ps1 -Path .\smartview.log -Function SALDOTIT

.EXAMPLE
    .\Parse-FwLogProfiler.ps1 -Path .\legado.log -Compare .\smartview.log -Top 30
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Path,

    [int] $Top = 25,

    [string] $Function,

    [string] $Root,

    [string] $Compare,

    [string] $CompareRoot,

    [double] $MinSeconds = 0.1,

    [switch] $Subtree,

    [string] $Csv
)

$ErrorActionPreference = 'Stop'
$inv = [System.Globalization.CultureInfo]::InvariantCulture

function ConvertTo-Num([string] $Value) {
    return [double]::Parse($Value, $inv)
}

$reCall = '^CALL\s+(?<name>.+?)\((?<src>[^()]*)\)\s+C\s+(?<c>\d+)\s+T\s+(?<t>[\d.]+)\s+M\s+(?<m>[\d.]+)\s*$'
$reFrom = '^--\s+FROM\s+(?<caller>.+?)\s+\((?<src>[^()]*)\)\s+\((?<line>\d+)\)\s+C\s+(?<c>\d+)\s+T\s+(?<t>[\d.]+)\s+M\s+(?<m>[\d.]+)\s*$'

function Read-Profiler([string] $LogPath) {
    if (-not (Test-Path -LiteralPath $LogPath)) {
        throw "Arquivo nao encontrado: $LogPath"
    }

    $funcs = @{}          # NOME -> objeto agregado da funcao
    $edges = @()          # arestas chamador -> chamado
    $header = [ordered]@{ File = (Split-Path -Leaf $LogPath) }
    $current = $null
    $parsed = 0

    foreach ($line in [System.IO.File]::ReadLines($LogPath)) {
        if ($line -match '^\s*(DateTime|Service|Method|Thread|T\.Timer)\s*\.*\s*:?\s*(.+?)\s*$') {
            $key = ($matches[1] -replace '\.', '')
            if (-not $header.Contains($key)) { $header[$key] = $matches[2].Trim() }
            continue
        }

        if ($line -match $reCall) {
            $name = $matches['name'].Trim().ToUpperInvariant()
            $current = $name
            if (-not $funcs.ContainsKey($name)) {
                $funcs[$name] = [pscustomobject]@{
                    Name    = $name
                    Source  = $matches['src'].Trim()
                    Calls   = 0
                    T       = 0.0
                    MaxCall = 0.0
                }
            }
            $f = $funcs[$name]
            $f.Calls += [int] $matches['c']
            $f.T     += ConvertTo-Num $matches['t']
            $m        = ConvertTo-Num $matches['m']
            if ($m -gt $f.MaxCall) { $f.MaxCall = $m }
            $parsed++
            continue
        }

        if ($line -match $reFrom) {
            if ($null -eq $current) { continue }
            $edges += [pscustomobject]@{
                Caller       = $matches['caller'].Trim().ToUpperInvariant()
                CallerSource = $matches['src'].Trim()
                CallerLine   = [int] $matches['line']
                Callee       = $current
                Calls        = [int] $matches['c']
                T            = ConvertTo-Num $matches['t']
                MaxCall      = ConvertTo-Num $matches['m']
            }
            $parsed++
            continue
        }
    }

    if ($parsed -eq 0) {
        throw "Nenhuma linha CALL/-- FROM reconhecida em '$LogPath'. O arquivo e realmente um log do FWLogProfiler?"
    }

    return [pscustomobject]@{
        Header = $header
        Funcs  = $funcs
        Edges  = $edges
    }
}

function Resolve-FunctionName($Profile, [string] $Needle) {
    $n = $Needle.ToUpperInvariant()
    if ($Profile.Funcs.ContainsKey($n)) { return $n }
    $hits = $Profile.Funcs.Keys | Where-Object { $_ -like "*$n*" } | Sort-Object { -$Profile.Funcs[$_].T }
    if (-not $hits) { return $null }
    return @($hits)[0]
}

# Descendentes do root no grafo de chamadas. Sem isso o ranking mistura
# ancestrais (login, UI, activate) que aparecem com Pct > 100% e nao sao o gargalo.
function Get-Subtree($Profile, [string] $RootName) {
    $byCaller = @{}
    foreach ($e in $Profile.Edges) {
        if (-not $byCaller.ContainsKey($e.Caller)) { $byCaller[$e.Caller] = New-Object System.Collections.ArrayList }
        [void] $byCaller[$e.Caller].Add($e.Callee)
    }
    $seen = @{ $RootName = $true }
    $queue = New-Object System.Collections.Queue
    $queue.Enqueue($RootName)
    while ($queue.Count -gt 0) {
        $cur = $queue.Dequeue()
        if (-not $byCaller.ContainsKey($cur)) { continue }
        foreach ($child in $byCaller[$cur]) {
            if (-not $seen.ContainsKey($child)) {
                $seen[$child] = $true
                $queue.Enqueue($child)
            }
        }
    }
    return $seen
}

function Write-Header($Profile) {
    Write-Output ''
    Write-Output '=============================================================='
    foreach ($k in $Profile.Header.Keys) {
        Write-Output ("{0,-10}: {1}" -f $k, $Profile.Header[$k])
    }
    Write-Output ("{0,-10}: {1} funcoes / {2} arestas" -f 'Parsed', $Profile.Funcs.Count, $Profile.Edges.Count)
    Write-Output '=============================================================='
}

# ------------------------------------------------------------------ parse
$A = Read-Profiler $Path
Write-Header $A

# ------------------------------------------------------------------ baseline 100%
$rootT = $null
$rootName = $null
if ($Root) {
    $rootName = Resolve-FunctionName $A $Root
    if ($rootName) { $rootT = $A.Funcs[$rootName].T }
    else { Write-Warning "Root '$Root' nao encontrado no log. Usando o maior T como referencia." }
}
if (-not $rootT) {
    $biggest = $A.Funcs.Values | Sort-Object T -Descending | Select-Object -First 1
    $rootName = $biggest.Name
    $rootT = $biggest.T
    if (-not $Root) {
        Write-Warning "Sem -Root: usando '$rootName' (maior T = $([math]::Round($rootT,3))s) como 100%. Informe -Root para ancorar na raiz da rotina medida."
    }
}
Write-Output ("Referencia de 100%: {0} = {1:N3}s" -f $rootName, $rootT)
Write-Output '(T = tempo INCLUSIVO. Nao some T de niveis diferentes.)'

$scopeA = $null
if ($Subtree) {
    $scopeA = Get-Subtree $A $rootName
    Write-Output ("Escopo: apenas descendentes de {0} ({1} funcoes)." -f $rootName, $scopeA.Count)
}
function Test-InScope($Scope, [string] $Name) {
    if ($null -eq $Scope) { return $true }
    return $Scope.ContainsKey($Name)
}

# ------------------------------------------------------------------ ranking global
$ranking = $A.Funcs.Values |
    Where-Object { $_.T -ge $MinSeconds -and (Test-InScope $scopeA $_.Name) } |
    Sort-Object T -Descending |
    Select-Object -First $Top |
    ForEach-Object {
        [pscustomobject]@{
            Funcao   = $_.Name
            Fonte    = $_.Source
            Chamadas = $_.Calls
            'T(s)'   = [math]::Round($_.T, 3)
            'Pct'    = if ($rootT -gt 0) { [math]::Round(100 * $_.T / $rootT, 1) } else { 0 }
            'ms/cal' = if ($_.Calls -gt 0) { [math]::Round(1000 * $_.T / $_.Calls, 3) } else { 0 }
            'Max(s)' = [math]::Round($_.MaxCall, 3)
        }
    }

Write-Output ''
Write-Output "### Ranking por tempo inclusivo (top $Top)"
$ranking | Format-Table -AutoSize

# ------------------------------------------------------------------ suspeitos de N+1
$nPlus1 = $A.Funcs.Values |
    Where-Object { $_.Calls -ge 1000 -and $_.T -ge $MinSeconds -and (Test-InScope $scopeA $_.Name) } |
    Sort-Object T -Descending |
    Select-Object -First $Top |
    ForEach-Object {
        [pscustomobject]@{
            Funcao   = $_.Name
            Fonte    = $_.Source
            Chamadas = $_.Calls
            'T(s)'   = [math]::Round($_.T, 3)
            'ms/cal' = [math]::Round(1000 * $_.T / $_.Calls, 3)
        }
    }

if ($nPlus1) {
    Write-Output "### Suspeitos de N+1 (>= 1000 chamadas) - custo por chamada baixo x volume alto"
    $nPlus1 | Format-Table -AutoSize
}

# ------------------------------------------------------------------ foco
if ($Function) {
    $fn = Resolve-FunctionName $A $Function
    if (-not $fn) {
        Write-Warning "Funcao '$Function' nao encontrada no log."
    }
    else {
        $f = $A.Funcs[$fn]
        Write-Output ''
        Write-Output '--------------------------------------------------------------'
        Write-Output ("FOCO: {0} ({1}) - {2} chamadas, T = {3:N3}s, maior chamada {4:N3}s" -f `
                $f.Name, $f.Source, $f.Calls, $f.T, $f.MaxCall)
        Write-Output '--------------------------------------------------------------'

        Write-Output ''
        Write-Output "### CALLERS de $fn (quem a chama, e de qual linha)"
        $A.Edges |
            Where-Object { $_.Callee -eq $fn } |
            Sort-Object T -Descending |
            Select-Object -First $Top |
            ForEach-Object {
                [pscustomobject]@{
                    Chamador = $_.Caller
                    Fonte    = $_.CallerSource
                    Linha    = $_.CallerLine
                    Chamadas = $_.Calls
                    'T(s)'   = [math]::Round($_.T, 3)
                    'PctF'   = if ($f.T -gt 0) { [math]::Round(100 * $_.T / $f.T, 1) } else { 0 }
                }
            } | Format-Table -AutoSize

        Write-Output "### CALLEES de $fn (onde $fn gasta o tempo dela) - % sobre T de $fn"
        $A.Edges |
            Where-Object { $_.Caller -eq $fn } |
            Group-Object Callee |
            ForEach-Object {
                $t = ($_.Group | Measure-Object T -Sum).Sum
                $c = ($_.Group | Measure-Object Calls -Sum).Sum
                [pscustomobject]@{
                    Chamada  = $_.Name
                    Fonte    = $A.Funcs[$_.Name].Source
                    Chamadas = $c
                    'T(s)'   = [math]::Round($t, 3)
                    'PctF'   = if ($f.T -gt 0) { [math]::Round(100 * $t / $f.T, 1) } else { 0 }
                    'ms/cal' = if ($c -gt 0) { [math]::Round(1000 * $t / $c, 3) } else { 0 }
                    Linhas   = (($_.Group | Sort-Object T -Descending | Select-Object -First 3 |
                            ForEach-Object { $_.CallerLine }) -join ',')
                }
            } |
            Sort-Object 'T(s)' -Descending |
            Select-Object -First $Top |
            Format-Table -AutoSize
    }
}

# ------------------------------------------------------------------ comparacao
if ($Compare) {
    $B = Read-Profiler $Compare
    Write-Output ''
    Write-Output '=============================================================='
    Write-Output ("COMPARACAO  A = {0}   x   B = {1}" -f $A.Header.File, $B.Header.File)
    Write-Output '=============================================================='

    # Raiz de B: normaliza os percentuais quando A e B medem rotinas/volumes diferentes
    # (legado x Smart View). Sem isso, comparar segundos absolutos engana.
    $rootBT = $null
    $rootBName = $null
    $needleB = if ($CompareRoot) { $CompareRoot } else { $Root }
    if ($needleB) {
        $rootBName = Resolve-FunctionName $B $needleB
        if ($rootBName) { $rootBT = $B.Funcs[$rootBName].T }
    }
    if (-not $rootBT) {
        $bigB = $B.Funcs.Values | Sort-Object T -Descending | Select-Object -First 1
        $rootBName = $bigB.Name
        $rootBT = $bigB.T
        Write-Warning "Raiz de B nao resolvida: usando '$rootBName' ($([math]::Round($rootBT,3))s) como 100% de B. Informe -CompareRoot."
    }
    Write-Output ("Raiz A: {0} = {1:N3}s   |   Raiz B: {2} = {3:N3}s" -f $rootName, $rootT, $rootBName, $rootBT)
    Write-Output 'Compare PctA x PctB (peso relativo). Delta em segundos so vale se A e B tem o MESMO volume.'

    $scopeB = $null
    if ($Subtree) { $scopeB = Get-Subtree $B $rootBName }

    $names = @($A.Funcs.Keys) + @($B.Funcs.Keys) | Sort-Object -Unique
    $cmp = foreach ($n in $names) {
        if ($Subtree -and -not ((Test-InScope $scopeA $n) -or (Test-InScope $scopeB $n))) { continue }
        $ta = if ($A.Funcs.ContainsKey($n)) { $A.Funcs[$n].T } else { 0 }
        $tb = if ($B.Funcs.ContainsKey($n)) { $B.Funcs[$n].T } else { 0 }
        $ca = if ($A.Funcs.ContainsKey($n)) { $A.Funcs[$n].Calls } else { 0 }
        $cb = if ($B.Funcs.ContainsKey($n)) { $B.Funcs[$n].Calls } else { 0 }
        if ([math]::Max($ta, $tb) -lt $MinSeconds) { continue }
        [pscustomobject]@{
            Funcao   = $n
            'CallsA' = $ca
            'T_A(s)' = [math]::Round($ta, 3)
            'PctA'   = if ($rootT -gt 0) { [math]::Round(100 * $ta / $rootT, 1) } else { 0 }
            'CallsB' = $cb
            'T_B(s)' = [math]::Round($tb, 3)
            'PctB'   = if ($rootBT -gt 0) { [math]::Round(100 * $tb / $rootBT, 1) } else { 0 }
            'Delta'  = [math]::Round($tb - $ta, 3)
            'Onde'   = if ($ta -eq 0) { 'so B' } elseif ($tb -eq 0) { 'so A' } else { 'ambos' }
        }
    }

    Write-Output "### Maior peso relativo em B do que em A (PctB - PctA) - top $Top"
    $cmp | Sort-Object { $_.PctB - $_.PctA } -Descending | Select-Object -First $Top | Format-Table -AutoSize

    Write-Output "### Maior custo absoluto em B - top $Top por Delta (so comparavel em volume igual)"
    $cmp | Sort-Object Delta -Descending | Select-Object -First $Top | Format-Table -AutoSize

    Write-Output "### Presente somente em B (custo introduzido pelo caminho B) - top $Top"
    $cmp | Where-Object { $_.Onde -eq 'so B' } | Sort-Object 'T_B(s)' -Descending |
        Select-Object -First $Top | Format-Table -AutoSize

    Write-Output "### Presente somente em A (custo que B nao paga) - top $Top"
    $cmp | Where-Object { $_.Onde -eq 'so A' } | Sort-Object 'T_A(s)' -Descending |
        Select-Object -First $Top | Format-Table -AutoSize
}

# ------------------------------------------------------------------ csv
if ($Csv) {
    $A.Funcs.Values |
        Sort-Object T -Descending |
        Select-Object Name, Source, Calls, T, MaxCall |
        Export-Csv -LiteralPath $Csv -NoTypeInformation -Encoding UTF8
    Write-Output ''
    Write-Output "CSV gravado em: $Csv"
}
