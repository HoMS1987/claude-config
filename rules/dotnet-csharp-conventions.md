---
paths:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
---

# .NET / C# Conventions

Sprache, Stack und Tests. Architektur, DI und Typ-Design stehen in `dotnet-core-principles.md`.

## Technologie-Stack

- **Immer die aktuelle .NET-LTS-Version** und die passende **C#-Version** verwenden
  (vor einem neuen Projekt nachschlagen, nicht aus dem Gedächtnis annehmen)
- **Nullable Reference Types** aktiviert, **file-scoped namespaces**, **global usings**

## Moderne C#-Features (Pflicht)

- **Primary Constructors** für Klassen mit DI- oder Konstruktor-Parametern; kein expliziter
  Konstruktor mit `_field = param`, wo ein Primary Constructor möglich ist
- **Collection Expressions**: `int[] numbers = [1, 2, 3];` statt `new[] { 1, 2, 3 }`
- **Expression-bodied Members**, **Pattern Matching** (switch expressions), **Using Declarations**,
  **Raw String Literals** für mehrzeilige Strings und SQL

## Async und Qualität

- Immer `async Task`, nie `async void`; nie `.Result` oder `GetAwaiter().GetResult()` (Deadlocks)
- `ConfigureAwait(false)` in Library-Code; `IAsyncEnumerable<T>` für große Datenmengen
- `Span<T>`/`Memory<T>` nur bei gemessener Notwendigkeit
- Keine auskommentierten Code-Blöcke in Commits
- Alle Eingaben validieren, parametrisierte Queries, keine Secrets im Code

## Testing

TDD (Red-Green-Refactor) gilt für **alle** Features, nicht nur für Bugfixes (siehe
`bugfix-tdd-first.md`). Test und Implementierung im selben Commit. Coverage-Ziele: Services ≥ 90 %,
Integration Tests ≥ 80 %. Kein `[Fact(Skip = "…")]` ohne Ticket.

- **xUnit v3** auf der **Microsoft.Testing.Platform (MTP)**, nicht VSTest
- **AwesomeAssertions** (`.Should()`), Apache-2.0-Fork von FluentAssertions 7.
  **Nicht FluentAssertions 8+** (kommerzielle Lizenz)
- **NSubstitute** statt Moq (`Task.FromResult()` für async Rückgaben)
- **AutoFixture** für Test-Daten, wo es Aufbau-Code spart (kein Pflicht-Paket)
- `IAsyncLifetime` für asynchrones Setup/Teardown

### Testprojekt-Aufbau

Ein Testprojekt pro Solution (`<Projekt>.Test`), Dateien `<KlasseUnterTest>Tests.cs`,
Methoden `Methode_Bedingung_ErwartetesErgebnis`. Internes über `InternalsVisibleTo` freigeben,
nicht `public` machen.

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

**`coverlet.collector`** ist ein VSTest-Datensammler und unter MTP wirkungslos, nicht verwenden.

**`Microsoft.NET.Test.Sdk` und `xunit.runner.visualstudio`** braucht nur der VSTest-Modus.
`dotnet test` unter MTP läuft nachweislich ohne sie; der Visual Studio Test Explorer nutzt für
xUnit-v3-Projekte laut xUnit-Doku automatisch MTP. Trotzdem **behalten**, wie es die xUnit-Doku
empfiehlt, solange nicht sicher ist, dass alle IDEs im Team (z. B. Rider, ältere Visual-Studio-Versionen)
MTP verwenden, sonst zeigen diese keine Tests an. Wer sie entfernt, muss `<OutputType>Exe</OutputType>`
explizit setzen (bleibt im Template ohnehin gesetzt).
Quelle: https://xunit.net/docs/getting-started/v3/microsoft-testing-platform
