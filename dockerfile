FROM mcr.microsoft.com/windows/servercore:ltsc2022

WORKDIR /azp/

COPY ./start.ps1 ./
COPY ./agent.zip ./

CMD powershell .\start.ps1