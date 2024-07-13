# Create image
The first step is to create a docker image. The scripts can be found in the same path as this ReadMe and the agent.zip file can be downloaded from DevOps.

A new image can be created using the command: ```docker build --tag "azp-agent:windows" .```.

> Important: PowerShell must be open in this path for the docker file to be used correctly.

# Create container
A new container can be created using the command below, whereby the name of the container (--name) and the name of the agent (AZP_AGENT_NAME) must be changed and a new, valid Personal Access Token must be used.

> Important: The token can and should be deleted/revoked again after the container has been created; the agent continues to run without the token after the initial setup.

## Command
``` '
docker run
-e DOCKER_HOST:"//./pipe/docker_engine"
-e AZP_URL="https://dev.azure.com/<organization>"
-e AZP_TOKEN="personalaccesstoken"
-e AZP_POOL="default"
-e AZP_AGENT_NAME="Docker Agent - Windows"
--name "azp-agent-windows"
-v //./pipe/docker_engine://./pipe/docker_engine
-v C:\azp\:C:\azp\
-v C:\bcartifacts.cache:C:\bcartifacts.cache
-v C:\ProgramData\BcContainerHelper\Extensions:C:\ProgramData\BcContainerHelper\Extensions
-it
azp-agent:windows
```
> //./pipe/docker_engine://./pipe/docker_engine

Makes the docker host available to the container. Every new container created with this agent will creat their build containers on the host.

> C:\bcartifact.cache
> C:\ProgramData\BcContainerHelper\Extensions

both are used for caching purposes

-e Environment variables

-v Binds - in this case the docker engine is passed through and the paths "host:docker" are mapped. The working directory is located in C:\azp\ and under C:\ProgramData