---
paths:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
---

# .NET / C# Conventions

## Technologie-Stack

- **Immer die aktuelle .NET-LTS-Version** und die dazu passende **C#-Version** verwenden
  (vor einem neuen Projekt nachschlagen, nicht aus dem Gedächtnis annehmen)
- **Nullable Reference Types** aktivieren
- **File-scoped namespaces** und **Global using statements**

## Moderne C#-Features (PFLICHT)

Beim Arbeiten mit aktuellem C# und .NET **MÜSSEN** moderne Sprachfeatures verwendet werden:

- **Primary Constructors** für Klassen mit DI oder Konstruktor-Parametern:
  ```csharp
  // PFLICHT — Primary Constructor verwenden
  public class UserService(IUserRepository repository, ILogger<UserService> logger) { }

  // VERBOTEN — Explizite Konstruktoren wenn Primary Constructor möglich
  public class UserService
  {
      private readonly IUserRepository _repository;
      public UserService(IUserRepository repository) { _repository = repository; }
  }
  ```
- **Collection Expressions**: `int[] numbers = [1, 2, 3, 4, 5];` statt `new[] { 1, 2, 3, 4, 5 }`
- **Expression-bodied Members**: `public string FullName => $"{FirstName} {LastName}";`
- **Record Types** für immutable DTOs
- **Pattern Matching** für komplexe Bedingungen (switch expressions)
- **Using Declarations** für automatisches Disposal
- **Raw String Literals** für mehrzeilige Strings und SQL-Queries

## Interface Design (PFLICHT)

- **Jeder Service braucht ein Interface** (Dependency Inversion Principle)
- **Primitive Typen/DTOs** in Interfaces, keine Framework-Typen (Stream, HttpClient)
- **Mockbar mit NSubstitute** — keine statischen Methoden in Interfaces
- **Naming**: `I` Prefix (z.B. `IUserService`)
- **Injection über Interface**, nie über konkrete Klasse

## Dependency Injection

- **Eingebauter DI-Container** von .NET (KISS)
- **Primary Constructors** für DI-Services
- **Service Lifetimes**: Singleton (stateless), Scoped (per-request), Transient (lightweight)
- **Options Pattern** für Konfiguration

## Architektur

- **Event-Driven Architecture** für lose Kopplung
- **CQRS** wo angemessen
- **Clean Architecture** mit klarer Schichtentrennung
- **MartenDB** für Event Sourcing (PostgreSQL), **EF Core** nur bei relationalen Anforderungen
- **Repository Pattern** mit Interfaces

## Testing

- **xUnit v3** auf der **Microsoft.Testing.Platform (MTP)**, nicht VSTest
- **AwesomeAssertions** für Assertions (`.Should()`) — Apache-2.0-Fork von
  FluentAssertions 7. **Nicht FluentAssertions 8+** (kommerzielle Lizenz)
- **NSubstitute** statt Moq
- **AutoFixture** für Test-Daten, wo es Aufbau-Code spart — kein Pflicht-Paket
- **Async-Testing**: IMMER `async Task`, nie `async void`; `Task.FromResult()` für NSubstitute; `IAsyncLifetime` für Setup/Teardown
- Niemals `.Result` oder `GetAwaiter().GetResult()` (Deadlock-Gefahr)

### Testprojekt-Aufbau

Ein Testprojekt pro Solution (`<Projekt>.Test`), Dateien `<KlasseUnterTest>Tests.cs`,
Methoden `Methode_Bedingung_ErwartetesErgebnis`. Internes wird über
`InternalsVisibleTo` im Produktivprojekt freigegeben, nicht `public` gemacht.

`global.json` im Repository-Root schaltet `dotnet test` auf MTP um:

```json
{
  "test": { "runner": "Microsoft.Testing.Platform" }
}
```

Testprojekt (Paketversionen: jeweils aktuelle stabile):

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework> <!-- aktuelle LTS -->
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    <OutputType>Exe</OutputType> <!-- xUnit v3 verlangt ein ausführbares Testprojekt -->
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="xunit.v3" Version="…" />
    <PackageReference Include="AwesomeAssertions" Version="…" />
    <PackageReference Include="NSubstitute" Version="…" />
    <PackageReference Include="Microsoft.Testing.Extensions.CodeCoverage" Version="…" />
    <!-- VSTest-Kompatibilität für IDEs ohne MTP-Unterstützung, siehe unten -->
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="…" />
    <PackageReference Include="xunit.runner.visualstudio" Version="…">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
    </PackageReference>
  </ItemGroup>
</Project>
```

**Unter MTP gilt (geprüft mit .NET SDK 10.0.4xx und xunit.v3 4.0):**

| Aufgabe | Richtig | Funktioniert NICHT |
|---------|---------|--------------------|
| Testfilter | `dotnet test --filter-class "*FooTests"`, `--filter-method`, `--filter-trait` | `--filter "ClassName=…"` (VSTest-Syntax → 0 Tests, Exit-Code 8) |
| Coverage | `dotnet test --coverage --coverage-output-format cobertura` mit `Microsoft.Testing.Extensions.CodeCoverage` | `--collect "XPlat Code Coverage"` mit `coverlet.collector` (Exit-Code 5) |

**`coverlet.collector`** ist ein VSTest-Datensammler und unter MTP wirkungslos —
nicht verwenden.

**`Microsoft.NET.Test.Sdk` und `xunit.runner.visualstudio`** braucht nur der
VSTest-Modus. `dotnet test` unter MTP läuft nachweislich ohne sie; der Visual
Studio Test Explorer nutzt für xUnit-v3-Projekte laut xUnit-Doku automatisch MTP. Trotzdem **behalten**, wie es die xUnit-Doku empfiehlt, solange
nicht sicher ist, dass alle IDEs im Team (z.B. Rider, ältere Visual-Studio-Versionen)
MTP verwenden — sonst zeigen diese keine Tests an. Wer sie entfernt, muss
`<OutputType>Exe</OutputType>` explizit setzen (bleibt im Template ohnehin gesetzt).
Quelle: https://xunit.net/docs/getting-started/v3/microsoft-testing-platform

## Code-Qualität

- **Aussagekräftige Namen** statt Kommentare
- **Keine auskommentierten Code-Blöcke** in Commits
- **ConfigureAwait(false)** in Library-Code
- **Span<T>/Memory<T>** nur bei gemessener Notwendigkeit
- **IAsyncEnumerable<T>** für große Datenmengen

## Sicherheit

- Alle Eingaben validieren
- Parameterized Queries gegen SQL Injection
- Keine Secrets im Code
