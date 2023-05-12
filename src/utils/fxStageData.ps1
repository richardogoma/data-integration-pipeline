Function StageData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$InstanceName,
        [Parameter(Mandatory=$true)][string]$Database,
        [Parameter(Mandatory=$true)][string]$Schema,
        [Parameter(Mandatory=$true)][string]$rawfilepath,
        [Parameter(Mandatory=$true)][string]$convertedfilepath,
        [Parameter(Mandatory=$false)][string]$SqlDataType = "VARCHAR(MAX)",
        [Parameter(Mandatory=$false)][pscredential]$SqlCred,
        [Parameter(Mandatory=$true)][string]$TableName,
        [Parameter(Mandatory=$false)][Switch]$Append
    )
    begin {
        # Check file existence and/or parse to TSV
        try {
            if(-not (Test-Path $rawfilepath)){
                Write-Error "Could not find: $rawfilepath" -ErrorAction Stop
            } 
            elseif((Test-Path $rawfilepath) -and ($rawfilepath -like '*.csv')){          
                $inputFile = $convertedfilepath -replace '\.csv$', '.tsv'

                # Parse CSV to tab-separated file
                Import-Csv -Path $rawfilepath | ConvertTo-Csv -Delimiter "`t" -NoTypeInformation `
                    | ForEach-Object {$_ -replace '"', ""} | Out-File -FilePath $inputFile -Encoding UTF8
                
                # Remove-Item -Path $rawfilepath

                # Retrieve file header
                $Data = Get-Content -Path $inputFile -TotalCount 1
            }
            elseif((Test-Path $rawfilepath) -and ($rawfilepath -like '*.tsv')){
                $inputFile = $rawfilepath
                $Data = Get-Content -Path $inputFile -TotalCount 1
            }
            else{
                Write-Error "Invalid file $rawfilepath" -ErrorAction Stop
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    process {
        try {
            # Parse and clean up the headers of the tab-separated file.
            $Header = ($Data, $Data | ConvertFrom-Csv -Delimiter "`t").PSObject.Properties.Name
            Write-Verbose "[Raw File Headers] $Header"
            $CleanHeader = @()
            
            foreach($h in $Header){
                $CleanValue = $h -Replace '[^a-zA-Z0-9_]',''
                $CleanHeader += $CleanValue
            }
            Write-Verbose "[Cleaned File Headers] $CleanHeader"
            
            # Build create table statement for staging table
            $StagingTableName = "temp_{0}" -f $TableName
            if(-not $Append){
                $tempsql = @("IF EXISTS (SELECT 1 FROM sys.tables WHERE name  = '$StagingTableName') DROP TABLE [$Database].[$Schema].[$StagingTableName]; `n")
                $tempsql += ("CREATE TABLE [$Database].[$Schema].[$StagingTableName]($($CleanHeader[0]) $SqlDataType `n")
            } else {
                    $tempsql = @("IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name  = '$StagingTableName') `n")
                    $tempsql += ("CREATE TABLE [$Database].[$Schema].[$StagingTableName]($($CleanHeader[0]) $SqlDataType `n")
            }
            $CleanHeader[1..$CleanHeader.Length] | ForEach-Object {$tempsql += ",$_ $SqlDataType `n"}
            $tempsql += ");"
            $tempsql = $tempsql -join "`n"
            Write-Verbose "[CREATE TABLE Statement] $tempsql"
        
            # Execute create table statement and bulk load data into staging table
            if($SqlCred){
                Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $tempsql -Username $SqlCred.UserName `
                    -Password $SqlCred.GetNetworkCredential().Password -ErrorAction Stop
                
                # Invoking the BCP (Bulk Copy Program) utility
                $cmd = "bcp '[$Database].[$Schema].[$StagingTableName]' in '$inputFile' -S'$InstanceName' -F2 -c -t'\t' -U'$($SqlCred.UserName)' -P'$($SqlCred.GetNetworkCredential().Password)'"
            } else {
                Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $tempsql -ErrorAction Stop

                # Invoking the BCP (Bulk Copy Program) utility
                $cmd = "bcp '[$Database].[$Schema].[$StagingTableName]' in '$inputFile' -S'$InstanceName' -F2 -c -t'\t' -T"
            }
            Write-Verbose "[BCP Command] $cmd"
            $cmdout = Invoke-Expression $cmd -ErrorAction Stop
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        Write-Host $cmdout -Separator "`n" -ForegroundColor Green
        Write-Host "Source data staging complete >>> initializing data integration...." -ForegroundColor Green
        Write-Verbose "[BCP Results] $cmdout"
        return @{'processed_data_headers'=$CleanHeader}
    }
    <#
        .SYNOPSIS
        This function takes a file in CSV or TSV format, cleans and parses its headers, 
        creates a staging table in a SQL Server database, and bulk loads the data from the file 
        into the staging table using the BCP utility.
    #>
}



