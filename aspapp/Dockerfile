#	https://learn.microsoft.com/en-us/dotnet/core/docker/build-container?tabs=linux&pivots=dotnet-8-0

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env
WORKDIR /aspapp

COPY . ./
RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /aspapp
COPY --from=build-env /aspapp/out .
EXPOSE 5006
ENTRYPOINT ["dotnet", "aspapp.dll"]

