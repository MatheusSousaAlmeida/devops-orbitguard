FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY OrbitGuard-API/OrbitGuard/OrbitGuard.csproj OrbitGuard/
RUN dotnet restore OrbitGuard/OrbitGuard.csproj

COPY OrbitGuard-API/OrbitGuard/ OrbitGuard/
WORKDIR /src/OrbitGuard
RUN dotnet publish OrbitGuard.csproj -c Release -o /app/publish --no-restore


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup orbitguard

COPY --from=build /app/publish .
RUN chown -R orbitguard:appgroup /app

USER orbitguard

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "OrbitGuard.dll"]