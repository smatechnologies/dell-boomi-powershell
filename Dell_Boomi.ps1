<#
This script executes a process on Dell Boomi and tracks it until completion.
If the process errors out in Dell Boomi, the script will fail in OpCon and 
the error message from Dell Boomi will appear in the OpCon job output.

Version: 1.0
Author: Bruce Jernell
SMA Technologies
#>

param(
    $user                # Script will prompt for this, should be provided when run in OpCon
    ,$password           # Script will prompt for this, should be provided when run in OpCon
    ,$accountId          # Should be hard coded or in a Global Property
    ,$atomId             # Should be hard coded or in a Global Property
    ,$processName        # Will be passed in by OpCon
    ,$processProperties  # Will be passed in by OpCon
    ,$waitTime = 3       # Can be passed in or hardcoded, effects how long the script waits to check the status of the execution
)

#Verify PS version is at least 3.0
if($PSVersionTable.PSVersion.Major -lt 3)
{
    Write-Host "Powershell version needs to be a least 3.0!"
    Exit 100
}

# Executes a process in Dell Boomi, also supports passing in properties
# Property format should be: PropName,PropValue;PropName2,PropValue2
Function ExecuteProcess($processId,$processName,$processProperties,$atomId,$accountId,$login)
{
    $url = "https://api.boomi.com/api/rest/v1/" + $accountId + "/executeProcess"

    if($processId)
    { 
        $processType = "processId" 
        $processValue = $processId
    }
    elseif($processName)
    { 
        $processType = "processName" 
        $processValue = $processName
    }
    else 
    {
        Write-Host "No process id/name specified!"
        Exit 400    
    }

    if($processProperties)
    {
        $properties = @()
        if($processProperties -like "*;*")
        { $splitter = $processProperties.Split(";") }
        else
        { $splitter = $processProperties }
        
        For($x=0;$x -lt $splitter.Count;$x++)
        {
            $splitter2 = $splitter[$x].Split(",")
            $properties += @{ "@type"="";"Name"=$splitter2[0];"Value"=$splitter2[1] }
        }

        $body = @{"ProcessProperties"=
                    @{ "@type"="ProcessProperties";"ProcessProperty"=$properties };
                    $processType=$processValue;
                    "atomId"=$atomId
                }
    }
    else
    {
        $body = @{ $processType=$processValue;"atomId"=$atomId }
    }

    try
    {
        $process = Invoke-Restmethod -Method POST -Uri $url -Body ($body | ConvertTo-Json -Depth 7) -Headers @{"Accept" = "application/json";"Authorization" = "Basic " + $login} -ContentType "application/json"
    }
    catch [Exception]
    {
        write-host $_
        write-host $_.Exception.Message
        Exit 401
    }

    return $process
}

# Retrieves execution history for processes, options to search by processName or executionId
Function ExecutionRecord($processName,$login,$accountId,$executionId)
{
    $url = "https://api.boomi.com/api/rest/v1/" + $accountId + "/ExecutionRecord/query"

    $processes = @()
    if($processName)
    {
        $processes += $processName
        $body = @{"QueryFilter" = 
                    @{
                        "expression"=
                        @{"argument" = $processes;"operator" = "EQUALS";"property" = "processName"}
                    }
                }
    }
    elseif($executionId)
    {
        $processes += $executionId
        $body = @{"QueryFilter" = 
                    @{
                        "expression"=
                        @{"argument" = $processes;"operator" = "EQUALS";"property" = "executionId"}
                    }
                }        
    }
    else 
    {
        Write-Host "Missing processName or executionId!"
        Exit 401    
    }

    try
    {
        $execRecord = Invoke-Restmethod -Method POST -Uri $url -Body ($body | ConvertTo-Json -Depth 7) -Headers @{"Accept" = "application/json";"Authorization" = "Basic " + $login} -ContentType "application/json"
    }
    catch [Exception]
    {
        write-host $_
        write-host $_.Exception.Message
        Exit 403
    }

    return $execRecord
}

# Force TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

<# 
!!! Comment these next two lines out once the script is in OpCon, pass as Encrypted Global Properties instead !!!

# Prompt for User/Pword..only for testing, use encrypted properties in OpCon
$user = Read-Host "Enter Username" 
$password = Read-Host "Enter Password" -AsSecurestring

# Conversion to Base64
# For testing: $string = [System.Text.Encoding]::UTF8.GetBytes(($user + ":" + ((New-Object PSCredential "user",$password).GetNetworkCredential().Password)))
# For Opcon:   $string = [System.Text.Encoding]::UTF8.GetBytes($user + ":" + $password)  
$login = [System.Convert]::ToBase64String($string)  
#>

# Properties must be in this format:  "PropertyName,PropertyValue;PropertyName2,PropertyValue2"
ExecuteProcess -processName $processName -atomId $atomId -login $login -accountId $accountId 
Write-Host "Running process $processName"

# Loops until the process is COMPLETE or in an ERROR state
$result = ExecutionRecord -processName $processName -login $login -accountId $accountId 
if($result.numberOfResults -gt 0)
{
    # Grab the latest executionId and loop until it completes or errors
    $executionId = $result.result[($result.result.Count-1)].executionId
    $status = $result.result[($result.result.Count-1)].status
    While($status -ne "COMPLETE" -and $status -ne "ERROR")
    {
        Start-Sleep -Seconds $waitTime
        $result = ExecutionRecord -executionId $executionId -login $login -accountId $accountId
        if($result.numberOfResults -ne 1)
        { 
            Write-Host "Problem getting status of $processName"
            Exit 405
        }
        $status = $result.result[0].status
    } 

    # If the process ends in Error, fail the script and write out the error message
    if($status -eq "ERROR")
    {
        $result.result[0]
        Write-Host $result.result[0].message
        Exit 402
    }
    else 
    {
        Write-Host "Process $processName complete!"
    }
}
else 
{
    Write-Host "Too many or no execution results found for "$runProcess.id
    Exit 404
}
