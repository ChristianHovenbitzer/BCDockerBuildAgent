# https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#create-and-build-the-dockerfile
 function Print-Header ($header) {
  Write-Host "`n${header}`n" -ForegroundColor Cyan
}

if (-not (Test-Path Env:AZP_URL)) {
  Write-Error "error: missing AZP_URL environment variable"
  exit 1
}

if (-not (Test-Path "\azp\agent\${Env:AZP_AGENT_NAME}"))
{
  mkdir "\azp\agent\${Env:AZP_AGENT_NAME}"
}

# Remove-Item Env:AZP_TOKEN

if ((Test-Path Env:AZP_WORK) -and -not (Test-Path $Env:AZP_WORK)) {
  New-Item $Env:AZP_WORK -ItemType directory | Out-Null
}

New-Item "\azp\agent\${Env:AZP_AGENT_NAME}" -ItemType directory -Force | Out-Null

# Let the agent ignore the token env variables
$Env:VSO_AGENT_IGNORE = "AZP_TOKEN"

Print-Header 'Clearing working dir'
if ((Get-ChildItem -Path "\azp\agent\${Env:AZP_AGENT_NAME}" | Measure-Object).Count -gt 0) {
  Remove-Item -Path "\azp\agent\${Env:AZP_AGENT_NAME}" -Recurse
}

Print-Header "1. Adding docker environment variable"

[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\azp\docker', 'Machine')

Print-Header "2. installing Azure Pipelines agent..."

Expand-Archive -Path "agent.zip" -DestinationPath "\azp\agent\$Env:AZP_AGENT_NAME"

try {
  Print-Header "3. Configuring Azure Pipelines agent..."

. ".\agent\$Env:AZP_AGENT_NAME\config.cmd" --unattended --agent "$(if (Test-Path Env:AZP_AGENT_NAME) { ${Env:AZP_AGENT_NAME} } else { hostname })" --url "$(${Env:AZP_URL})" --auth PAT --token "$Env:AZP_TOKEN" --pool "$(if (Test-Path Env:AZP_POOL) { ${Env:AZP_POOL} } else { 'Default' })" --work "$(if (Test-Path Env:AZP_WORK) { ${Env:AZP_WORK} } else { '_work' })" --replace

Print-Header "4. Running Azure Pipelines agent..."

. ".\agent\$Env:AZP_AGENT_NAME\run.cmd"
} finally {
  Print-Header "Cleanup. Removing Azure Pipelines agent..."

. ".\agent\$Env:AZP_AGENT_NAME\config.cmd" remove --unattended --auth PAT --token "${Env:AZP_TOKEN}"
}

# docker build --tag "azp-agent:windows" .
# docker run -e DOCKER_HOST:"//./pipe/docker_engine" -e AZP_URL="https://azure.devops.com/<organization>" -e AZP_TOKEN="personalaccesstoken" -e AZP_POOL="default" -e AZP_AGENT_NAME="Docker Agent - Windows" --name "azp-agent-windows" -it -v //./pipe/docker_engine://./pipe/docker_engine azp-agent:windows