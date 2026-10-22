---
paths:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
---

# .NET-Prinzipien: Architektur, Design, Konfiguration

Gilt beim Lesen, Planen, Reviewen und Schreiben von C#-Code. Ergänzt `dotnet-csharp-conventions.md`
(Sprache, Stack, Tests). Bei Reviews und Analysen wird jeder Befund gegen diese Prinzipien begründet
(SOLID, Clean Code, Clean Architecture, DDD als gemeinsames Vokabular).

## Interfaces und Dependency Injection

- **Interface-First:** Jeder Service hat ein Interface (`I`-Präfix) und wird über das Interface
  injiziert. Interfaces liegen neben der Implementierung, nicht in einem `Interfaces/`-Ordner.
- Interfaces verwenden primitive Typen/DTOs, keine Framework-Typen (`Stream`, `HttpClient`), und
  bleiben mit NSubstitute mockbar (keine statischen Member).
- Jedes `new` einer Klasse mit Verhalten (nicht Value Objects/DTOs) braucht eine Begründung.
  Kein Service Locator, keine statischen Singletons, keine `Factory`-Klassen, wo DI genügt.
- **Container:** der eingebaute MS-DI-Container. Registrierung per **Scrutor**-Assembly-Scanning nach
  Namenskonvention (`*Handler`, `*Service`, `*Repository`, `*Validator`), nicht jede Klasse von Hand.
- **AOT:** Scrutor ist reflection-basiert und AOT-inkompatibel. Für AOT-Targets **Jab**
  (Source-Generator, MIT, `pakrym/jab`):

  ```csharp
  [ServiceProvider]
  [Singleton(typeof(IClock), typeof(SystemClock))]
  [Transient(typeof(IHeadingExtractor), typeof(MarkdownHeadingExtractor))]
  internal partial class AppServices { }
  ```

  Pure.DI nur für Greenfield-Projekte, die den Composition Root bewusst neu modellieren, mit ADR.
- Service Lifetimes: Singleton (stateless), Scoped (per Request), Transient (leichtgewichtig).

## Clean Architecture

| Schicht | Inhalt | Darf referenzieren |
|---------|--------|--------------------|
| `*.Domain` | Entities, Value Objects, Domain Services. Keine Framework-Referenzen, kein `Microsoft.Extensions.*`, kein IO | nichts |
| `*.Application` | Use Cases, Orchestrierung, definiert die Interfaces | Domain |
| `*.Infrastructure` | Implementiert die Interfaces: IO, HTTP, DB, Messaging, TOML-Reader. **Messaging/Event-Publishing nur hier** | Application, Domain |
| `*.Console`/`*.Api`/`*.Service` | Composition Root, DI-Registrierung, `Program.cs` | alle, nur zur Verdrahtung |

**Vertical Slices** innerhalb der Application-Schicht: ein Ordner pro Feature
(`Features/CreateOrder/` mit Command, Handler, Validator, Result), nicht nach technischen Kategorien
(`Handlers/`, `Validators/`). Ordnerstruktur spiegelt den Namespace 1:1.

**Persistenz:** **MartenDB** (PostgreSQL) für Event Sourcing, **EF Core** nur bei relationalen
Anforderungen. Repository-Pattern mit Interfaces.

## Event-Driven Architecture: wo sinnvoll

Events, wo lose Kopplung, asynchrone Verarbeitung oder Audit-Trails gefragt sind, nicht dogmatisch:

- **Domain Events** in-process, **Integration Events** über einen Broker (z. B. NATS, RabbitMQ)
- **Idempotenz ist Pflicht:** Handler verkraften Duplikate (Event-ID-Deduplizierung, Upsert)
- **Kein Event für synchrones CRUD**
- CQRS (getrennte Read-/Write-Modelle) wo angemessen; CQS auf Methodenebene immer: eine Methode
  fragt ab **oder** ändert Zustand, nie beides (`GetOrCreate…` ist ein Smell)

## Typ-Design

| Typ | Wann |
|-----|------|
| `record` | Default für immutable Datenhalter: DTOs, Events, Commands, Queries, Value Objects |
| `readonly record struct` | Kleine Value Objects (1–3 primitive Felder): IDs, Koordinaten, Durations |
| `record struct` | Nur wenn Mutation gezielt gebraucht wird |
| `class` | Nur bei Identität, Verhalten, Lifecycle oder wenn DI/Vererbung es erfordert |
| `struct` | Nur performance-kritisch, wo `record struct` nicht passt |

- Jede neue `class` muss sich gegenüber `record` rechtfertigen.
- `init`-only Properties, `readonly` Felder, Collections in Public APIs als
  `IReadOnlyList<T>`/`ImmutableArray<T>`.
- **Sealed by default.** Komposition und Decorator statt Vererbung; Vererbung nur für echte,
  stabile *is-a*-Hierarchien.
- **Value Objects statt Primitives:** `OrderId` statt `int`, `Temperature` statt `double`.

## Clean Code

- Funktionen max. ~10–15 Zeilen, eine Abstraktionsebene, Early Returns statt verschachtelter `if`
- Kommentare nur als `// TODO` und `// WHY:` bei nicht offensichtlichen Invarianten
- Exceptions statt Error-Codes oder `bool`-Fehlerflags
- Keine Magic Numbers/Strings; jeder Fakt, jede Validierungsregel, jede Konstante existiert
  **genau einmal** (Validierung im Domain-Modell, nicht im Controller)
- Etablierte Patterns statt Eigenbau (Repository, Strategy, Decorator, Mediator, Options).
  Neues Muster nur, wenn keins passt, dann mit ADR
- YAGNI schlägt DRY, wenn die Abstraktion spekulativ wäre; drei ähnliche Zeilen sind besser als
  eine schlechte Abstraktion

## Settings: TOML mit Live-Update

- Datei heißt `settings.toml`, nie `appsettings.json` in Neu-Projekten. Konfiguration nur dort, nicht
  parallel in Umgebungsvariablen mit eigener Bedeutung.
- **Tomlyn.Extensions.Configuration** mit `reloadOnChange: true`, im Code **`IOptionsMonitor<T>`**
  (`CurrentValue`). `IOptions<T>` liest nur den Startwert und ist für Hot-Reload falsch.
- Fail-fast: `AddOptions<T>().Bind(…).ValidateDataAnnotations().ValidateOnStart()`.

```csharp
builder.Configuration.AddTomlFile("settings.toml", optional: false, reloadOnChange: true);
builder.Services.Configure<MySettings>(builder.Configuration.GetSection("MySection"));
```

## Zeit: NodaTime

Kein `DateTime.Now`/`DateTime.UtcNow`. Zeit kommt über **NodaTime** und ein injiziertes `IClock`
(Tests mit `FakeClock`). Zeitpunkte als `Instant`, Zeitzonen über `DateTimeZone`.

## Observability: Serilog und OpenTelemetry

- **Serilog** (Sinks Console, File, bei Bedarf Seq) mit strukturierten Properties:
  `LogInformation("Order {OrderId} created", orderId)`, nie String-Konkatenation
- **OpenTelemetry** für Traces und Metrics, Export per OTLP; Trace-Context wird mit Serilog korreliert
- Metrics über `System.Diagnostics.Metrics.Meter`: Counter, Histogram, ObservableGauge
- Nie `Console.WriteLine`/`Debug.WriteLine` zum Loggen, nie PII oder Secrets im Log
- Log-Level: `Information` Normalbetrieb, `Warning` behebbare Anomalie, `Error` echter Fehler,
  `Critical` nur, wenn der Betrieb stoppt

## Code-Navigation mit dem C# Language Server

Ist das `LSP`-Tool verfügbar (Plugin `csharp-lsp`), wird es bevorzugt: Go-to-Definition und Find
References statt Textsuche, Hover für Typen und Signaturen, Diagnostics nach Änderungen. `grep` für
Strings, Kommentare und Projekt-/Konfigurationsdateien. Maßgeblich für „kompiliert“ und „Tests grün“
bleiben `dotnet build` und `dotnet test`. Liefert LSP nichts (Projekt nicht geladen), auf `grep` und
den Build-Output zurückfallen.

## Review-Checkliste (Pflicht für Reviews und Code-Analysen)

Jeder Fund bekommt eine Kategorie, ein Severity-Label (CRITICAL / WARNING / INFO / SUGGESTION) und
einen Satz, der das verletzte Prinzip nennt.

- **SOLID & Clean Code:** SRP-Verletzung; direkte `new`-Instanzierung oder konkrete Klasse statt
  Interface; Magic Number/String; Funktion über 15 Zeilen oder gemischte Abstraktionsebenen
- **Architektur:** Framework-Abhängigkeit in Domain; Messaging außerhalb Infrastructure; Verstoß
  gegen eine ADR ohne Begründung; Vertical Slice über fremde Ordner verteilt
- **Typ-Design:** `class` statt `record` ohne Grund; Vererbung statt Komposition; Primitives statt
  Value Objects; mutable Collection in Public API
- **Tests:** fehlende Tests oder Coverage unter Ziel; Test ohne Assertion; Test nach der
  Implementierung; Bugfix ohne 5-Why-Analyse
- **Konfiguration:** `IOptions<T>` statt `IOptionsMonitor<T>`; `appsettings.json` statt
  `settings.toml`; manuelle DI-Registrierung, wo Scanning greift; Scrutor in AOT-Target
- **Observability:** `Console.WriteLine`/`Debug.WriteLine`; String-Konkatenation im Log; PII/Secrets
  im Log; fehlende Trace-Korrelation
- **Zeit & Threading:** `DateTime.Now`/`UtcNow` statt NodaTime; blockierendes IO in async-Kontext;
  fehlendes `ConfigureAwait(false)` in Library-Code
- **Sonstiges:** String-Konkatenation in Schleifen statt `StringBuilder`; Eigenbau statt etabliertem
  Pattern
