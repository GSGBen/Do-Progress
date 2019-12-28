<#
.synopsis
    - shows a colored loading bar in the powershell window
.description
    - same as retryW's version, but with the numbers at the end optionally removed
.parameter ShowStats
    - If this flag is used, the original numbers are shown at the end of the bar
.notes
    - Author: retyW
    - Modified by: Ben Renninson
    - Email: ben@goldensyrupgames.com
    - From: https://github.com/GSGBen/Do-Progress
#>
function Do-Progress([int]$count,[int]$total, [int]$started, [switch]$ShowStats) {
    # Calculate percentage
    [int]$percentComplete = 100 / $total * $count
    # Keep the actual percentage for displaying number on screen
    $displayPercent = $percentComplete
    # Make 100% equal to 50, as it will fit a default PowerShell window. 100 characters would be excessive.
    [int]$percentComplete = $percentComplete / 2

    # Empty variables from previous run
    # Used to create 'chunks' to display in console with the least number of Write-Hosts. Significantly increases performance.
    $completeBarPre = ""
    $completeBarPost = ""
    $completeString = ""
    $startedBarPre = ""
    $startedBarPost = ""
    $startedString = ""
    $incompleteBarPre = ""
    $incompleteBarPost = ""
    $incompleteString = ""

    # Calculate what character should be used in each position
    for($i = 0; $i -le $percentComplete; $i++) {
        if ($i -eq 24) {
            $completeString += $displayPercent.ToString()[0]
        } elseif ($i -eq 25){
            $completeString += $displayPercent.ToString()[1]
        } elseif ($i -eq 26){
            if($displayPercent -lt 100) {
                $completeString += "%"
            } else {
                $completeString += $displayPercent.ToString()[2]
            }
        } elseif ($i -eq 27){
            if($displayPercent -eq 100) {
                $completeString += "%"
            } else {
                $completeBarPost += "-"
            }
        } else {
            if ($i -lt 24) {
                $completeBarPre += "-"
            } else {
                $completeBarPost += "-"
            }
        }
    }
    if($started) {
        [int]$percentStarted = 100 / $total * $started
        [int]$percentStarted = $percentStarted / 2
        for(; $i -le $percentStarted; $i++) {
            if ($i -eq 24) {
                $startedString += $displayPercent.ToString()[0]
            } elseif ($i -eq 25){
                $startedString += $displayPercent.ToString()[1]
            } elseif ($i -eq 26){
                if($displayPercent -lt 100) {
                    $startedString += "%"
                } else {
                    $startedString += $displayPercent.ToString()[2]
                }
            } elseif ($i -eq 27){
                if($displayPercent -eq 100) {
                    $startedString += "%"
                } else {
                    $startedBarPost += "-"
                }
            } else {
                if ($i -lt 24) {
                    $startedBarPre += "-"
                } else {
                    $startedBarPost += "-"
                }
            }
        }
    }
    for(;$i -le 50; $i++) {
        if ($i -eq 24) {
            $incompleteString += $displayPercent.ToString()[0]
        } elseif ($i -eq 25){
            $incompleteString += $displayPercent.ToString()[1]
        } elseif ($i -eq 26){
            $incompleteString += "%"
        } else {
            if ($i -lt 24) {
                $incompleteBarPre += "-"
            } else {
                $incompleteBarPost += "-"
            }
        }
    }

    # Return carriage. Allows us to overwrite the current line within the console.
    Write-Host "`r" -NoNewline

    # Draw the loading bar. Unsure if it would be more efficient to check if Post vars are empty and exclude if so. Will have to test.
    Write-Host "[" -NoNewline -BackgroundColor Black
    Write-Host $completeBarPre -BackgroundColor Green -ForegroundColor Green -NoNewline
    Write-Host $completeString -BackgroundColor Green -ForegroundColor Black -NoNewline
    Write-Host $completeBarPost -BackgroundColor Green -ForegroundColor Green -NoNewline
    Write-Host $startedBarPre -BackgroundColor Yellow -ForegroundColor Yellow -NoNewline
    Write-Host $startedString -BackgroundColor Yellow -ForegroundColor Black -NoNewline
    Write-Host $startedBarPost -BackgroundColor Yellow -ForegroundColor Yellow -NoNewline
    Write-Host $incompleteBarPre -BackgroundColor Red -ForegroundColor Red -NoNewline
    Write-Host $incompleteString -BackgroundColor Red -ForegroundColor White -NoNewline
    Write-Host $incompleteBarPost -BackgroundColor Red -ForegroundColor Red -NoNewline
    Write-Host "]" -NoNewline -BackgroundColor Black

    # Append the stats to the end of the loading bar, if specified
    if ($ShowStats)
    {
        if ($started) {
            Write-Host " Completed: $count, Started: $started, Total: $total" -NoNewline #"`r"
        } else {
            Write-Host " Completed: $count, Total: $total" -NoNewline #"`r"
        }
    }

    if($count -eq $total){
        # Go to new line, so external script doesn't write over the bar or on same line
        # Write another line so there's an empty line after the loading bar. Looks far cleaner.
        Write-Host ""
        Write-Host ""
    }

}

<#
.synopsis
    - runs Do-Progess over a specified length
.description
    - helper function that handles a simple time loop of Do-Progress
    - doesn't really work like a proper timer due to screen-writing delays and such.
      If you're using this for a visual thing, test it on your target platform.
      Can kind of think in milliseconds.
.parameter Total
    - total amount to run over
.parameter Interval
    - the number to increment per run, and the milliseconds to sleep for per run
.parameter YellowMultiplier
    - how many intervals ahead of the green bar you want the yellow bar to be
.parameter ShowStats
    - If this flag is used, the original numbers are shown at the end of the bar
.notes
    - Author: Ben Renninson
    - Email: ben@goldensyrupgames.com
    - From: https://github.com/GSGBen/Do-Progress
#>
function Loop-Progress
{
    Param
    (
        [Parameter(Mandatory=$true)][int]$Total,
        [Parameter(Mandatory=$true)][int]$Interval,
        [Parameter(Mandatory=$false)][int]$YellowMultiplier = 0,
        [Parameter(Mandatory=$false)][switch]$ShowStats
    )

    for ([int]$Count = 0; $Count -le $Total; $Count +=$Interval)
    {
        # 'started' is the term the original function uses to show the number of items in the count you've started, i.e. the yellow bar
        # it doesn't refer to where the current run is starting from
        # e.g. total = 100, count = 10, started = 20 means the bar is green up to 10, yellow up to 20, then red up to 100
        $Started = [math]::Min($Count + ($Interval * $YellowMultiplier), $Total)
        Do-Progress -count $Count -total $Total -started $Started -ShowStats:$ShowStats
        Start-Sleep -Milliseconds $Interval
    }
}

# Export the function
Export-ModuleMember -Function *
