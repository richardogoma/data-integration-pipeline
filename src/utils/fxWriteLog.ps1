Function WriteFunction {
    [CmdletBinding()]
    param (
      [Parameter(Mandatory=$true)][pscustomobject]$data, 
      [Parameter(Mandatory=$true)][array]$header, 
      [Parameter(Mandatory=$true)][string]$file
    )
    begin {
      $retryCount = 0
      $maxRetries = 10
    }
    process {
      while ($retryCount -lt $maxRetries) {
        try {
          if (!(Test-Path $file)) {
            $data | Select-Object $header | ConvertTo-Csv -Delimiter "|" -NoTypeInformation `
              | Out-File $file -Encoding utf8
          } else {
            $data | Select-Object $header | ConvertTo-Csv -Delimiter "|" -NoTypeInformation `
              | Select-Object -Skip 1 | Out-File $file -Encoding utf8 -Append
          }        
          break
        } catch [System.IO.IOException] {
          if ($_.Exception.Message -like "*being used by another process*") {
            $retryCount++
            Write-Host "File is locked, retrying in 1 second..."
            Start-Sleep -Seconds 1
          } else {
            Write-Error "Unexpected error: $_"
            break
          }
        }
      }
    }
    end {
      if ($retryCount -eq $maxRetries) {
        Write-Host "Maximum number of retries reached, giving up."
      }
    }
    <#
        .SYNOPSIS
        This function takes in data, header, and a file path as parameters, and writes the data 
        to the specified file with a pipe delimiter, handling any file locking issues by retrying up to 10 times.
    #>
}