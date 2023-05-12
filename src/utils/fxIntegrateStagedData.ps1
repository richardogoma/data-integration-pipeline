Function IntegrateData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$InstanceName,
        [Parameter(Mandatory=$true)][string]$Database,
        [Parameter(Mandatory=$true)][string]$Schema,
        [Parameter(Mandatory=$false)][pscredential]$SqlCred,
        [Parameter(Mandatory=$true)][string]$TableName,
        [Parameter(Mandatory=$true)][array]$DataColumns,
        [Parameter(Mandatory=$false)][string]$PrimaryKey = "id"
    )
    begin {
        # Generate update statement body for stored procedure
        $update = @()
        $DataColumns[0..$DataColumns.Length] | ForEach-Object {$update += ",Target.$_ = Source.$_ `n"}
        $update += ";"
        $update = $update -join "`n"
        $UpdateBody = $($update.substring(1))

        # Generate insert statement body for stored procedure
        $insert_schema = @()
        $DataColumns[0..$DataColumns.Length] | ForEach-Object {$insert_schema += ",$_ `n"}
        $insert_schema = $insert_schema -join "`n"
        $InsertBody = $($insert_schema.substring(1))

        $insert_values = @()
        $DataColumns[0..$DataColumns.Length] | ForEach-Object {$insert_values += ",Source.$_ `n"}
        $insert_values = $insert_values -join "`n"
        $ValuesBody = $($insert_values.substring(1))

        $FileVariables=@(
            "Schema=$Schema",
            "TableName=$TableName",
            "PrimaryKey=$PrimaryKey"
        )

        $InputFile = "src/data/transform-data-template.sql"
        $ModifiedInputFile = "src/data/transform-data-actual.sql"

        # Read the SQL script file
        $Script = Get-Content -Path $InputFile -Raw

        # Replace the placeholders with actual values using the format operator
        $ModifiedScript = $Script -f $UpdateBody, $InsertBody, $ValuesBody

        # Write the modified script to the output file
        $ModifiedScript | Out-File -FilePath $ModifiedInputFile -Encoding UTF8

        $Params=@{
            ServerInstance=$InstanceName
            Database=$Database
            InputFile=$ModifiedInputFile
            Variable=$FileVariables
        }
    }
    process {
        try {
            if($SqlCred){
                $resp = Invoke-Sqlcmd @Params -Username $SqlCred.UserName -Password $SqlCred.GetNetworkCredential().Password -ErrorAction Stop
            } else {
                $resp = Invoke-Sqlcmd @Params -ErrorAction Stop
            }
            # Validate response
            if ($resp.Count -eq 0) {
                Write-Error "[$Database].[$Schema].[$TableName] doesn't exist. Refer to src/assets/table_schemas.sql, create table and try again." -ErrorAction Stop
            } else {
                $result_schema = @("Timestamp", "Instance", "Table", "UpdatedRows", "InsertedRows")

                $result = New-Object PSObject -Property @{'Timestamp'=Get-Date;'Instance'=$InstanceName; `
                    'Table'="[$Database].[$Schema].[$TableName]";'UpdatedRows'=$resp.UpdatedRows[0]; `
                    'InsertedRows'=$resp.InsertedRows[1]
                }
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        Remove-Item -Path $ModifiedInputFile
        Write-Host "Data integration complete ...." -ForegroundColor Green
        return @{'log'=$result;'log_header'=$result_schema}
    }
    <#
        .SYNOPSIS    
        This function integrates data from a staging table in a SQL Server database into a specified database table 
        by executing an SQL script containing insert and update statements, and returns a PSObject with 
        the updated and inserted row counts along with metadata.
    #>
}