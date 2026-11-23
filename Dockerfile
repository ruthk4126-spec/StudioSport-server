FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY *.slnx ./
COPY StudioSport.API/*.csproj StudioSport.API/
COPY StudioSport.Core/*.csproj StudioSport.Core/
COPY StudioSport.Data/*.csproj StudioSport.Data/
COPY StudioSport.Service/*.csproj StudioSport.Service/
COPY StudioSport.Tests/*.csproj StudioSport.Tests/
RUN dotnet restore StudioSport.API/StudioSport.API.csproj

COPY . .

RUN dotnet publish StudioSport.API/StudioSport.API.csproj -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .

# לתיקיית הלוגים של NLog (גם כשהמערכת מוגנת-כתיבה). בחינמי של Render אין
# דיסק קבוע, ולכן התיקייה מוחלפת בסימלינק ל-/tmp — הקובץ עצמו לא נשמר בין
# אתחולים, אבל האפליקציה לא נופלת מניסיון לפתוח קובץ שאין הרשאה לכתוב לו.
RUN mkdir -p /app/logs /tmp/logs \
    && rm -rf /app/logs \
    && ln -s /tmp/logs /app/logs \
    && chown -R $APP_UID:$APP_UID /tmp/logs

USER $APP_UID

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
EXPOSE 8080

ENTRYPOINT ["dotnet", "StudioSport.API.dll"]