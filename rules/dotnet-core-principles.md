---
paths:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
---

# .NET Core-Prinzipien: SOLID, Clean Code, Clean Architecture, TDD, Settings

Diese Rule bündelt die Kern-Prinzipien, nach denen jeder C#-Code
bewertet, reviewt und geplant wird. Sie ergänzt `dotnet-csharp-conventions.md`
(das sich auf moderne C#-Syntax fokussiert) um die architektonischen und
methodischen Grundlagen.

**Wann gilt diese Rule?** Immer wenn C#-Code angefasst wird — also beim Lesen,
Analysieren, Reviewen, Planen oder Schreiben von `.cs`/`.csproj`-Dateien. Bei
Code-Analysen (z.B. bei Reviews oder Planungen) MUSS jeder Befund
gegen diese Prinzipien begründet werden.

## 1. SOLID

Fünf Grundregeln für wartbares OO-Design. Jeder Befund an einer Klasse soll
auf eine konkrete SOLID-Verletzung verweisen können.

| Prinzip | Kurzregel | Typischer Smell |
|---------|-----------|-----------------|
| **S**ingle Responsibility | Eine Klasse hat genau einen Grund zur Änderung | Klasse kombiniert Parsing, Rendering und File-IO |
| **O**pen/Closed | Erweiterbar ohne Modifikation existierenden Codes | `switch` über Typen, der bei neuer Variante geändert werden muss |
| **L**iskov Substitution | Subtypen müssen Basistyp ersetzbar bleiben | Überschriebene Methode wirft `NotSupportedException` |
| **I**nterface Segregation | Viele schmale Interfaces statt eines dicken | Interface mit 15 Methoden, Clients brauchen nur 2 |
| **D**ependency Inversion | Abhängigkeit auf Abstraktion, nicht Implementierung | `new FileReader(...)` statt injizierter `IFileReader` |

Typisches SRP-Beispiel (Verletzung):

```csharp
public class Program
{
    public static void Main(string[] args)
    {
        var content = File.ReadAllText("README.md");   // IO
        var toc = Regex.Matches(content, "^#+\\s+.+"); // Parsing
        Console.WriteLine(toc);                         // Rendering
    }
}
```

Fix: drei Verantwortlichkeiten in drei Typen — `IMarkdownSource`,
`IHeadingExtractor`, `ITocRenderer` — über DI verdrahtet.

**Merksatz — Interface-First und DI-First sind Default:**
Programmierung gegen Interfaces ist die Standard-Arbeitsweise, nicht die
Ausnahme. Jede konkrete `new`-Instanzierung einer Klasse mit Verhalten
(nicht Value Objects/DTOs) braucht eine explizite Begründung. DI ist der
Default-Weg für Abhängigkeiten — kein Service Locator, keine statischen
Singletons, keine Factory-Klassen wo der Container genügt.

## 2. Clean Code

Fokus auf Lesbarkeit und minimalen kognitiven Aufwand.

- **Aussagekräftige Namen**: `GenerateToc` statt `Proc`, `heading` statt `h`
- **Kleine Funktionen**: max ~10–15 Zeilen, eine Abstraktionsebene
- **Keine Kommentare außer `// TODO` und `// WHY:`-Kommentaren** bei
  nicht-offensichtlichen Invarianten — der Code muss sich selbst erklären
- **Exceptions statt Error-Codes**: keine int-Return-Codes, keine `bool`-Flags
  die bei `false` Fehlschlag bedeuten
- **Konsistenz**: gleiche Aufgaben werden gleich benannt und strukturiert
- **Keine Magic Numbers/Strings**: Konstanten mit sprechendem Namen
- **Early Returns**: keine tief verschachtelten `if`-Bäume

## 3. Clean Architecture

Abhängigkeitsregel: der innere Ring darf nichts vom äußeren wissen.

```
┌──────────────────────────────────────────┐
│  Infrastructure (IO, DB, HTTP, File)     │  ← abhängig von innen
│  ┌────────────────────────────────────┐  │
│  │  Application (Use Cases, Services) │  │  ← abhängig von Domain
│  │  ┌──────────────────────────────┐  │  │
│  │  │  Domain (Entities, Rules)    │  │  │  ← weiß von nichts
│  │  └──────────────────────────────┘  │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

**Konkret für .NET-Projekte:**

- **Domain-Schicht** (`*.Domain`): POCOs, Value Objects, Domain Services.
  Keine Framework-Referenzen, kein `Microsoft.Extensions.*`, kein IO.
- **Application-Schicht** (`*.Application`): Use Cases, Orchestrierung,
  definiert Interfaces (`IFileReader`, `IHeadingExtractor`). Darf Domain
  referenzieren, nicht Infrastructure.
- **Infrastructure-Schicht** (`*.Infrastructure`): Implementiert die
  Interfaces aus Application — File-IO, HTTP, DB, Messaging, Tomlyn-Reader.
  **Messaging/Event-Publishing erfolgt ausschließlich hier** — nie direkt
  aus Domain oder Application.
- **Entry-Point** (`*.Console`, `*.Api`, `*.Service`): Composition Root,
  DI-Registrierung, `Program.cs`. Referenziert alle Schichten nur zur
  Verdrahtung.

**Smell-Test:** Wenn eine Domain-Klasse `using System.IO;` braucht, ist das
ein Architektur-Bruch.

## 4. Test-Driven Development (Red-Green-Refactor)

TDD gilt für **alle** Feature-Arbeiten, nicht nur für Bugfixes.

**Der Zyklus:**

1. **RED** — Failing Test schreiben, der das gewünschte Verhalten spezifiziert.
   Test läuft, schlägt erwartet fehl (`dotnet test` zeigt rot).
2. **GREEN** — Minimalste Implementierung, die den Test grün macht. Kein
   Extra-Code, keine Verallgemeinerung.
3. **REFACTOR** — Code säubern, solange die Tests grün bleiben.
   SOLID/Clean Code anwenden, Duplikation entfernen.

**Commit-Disziplin:** Test + Implementierung gehören in **denselben** Commit.
Kein Feature ohne Test. Kein Test ohne Rot-Phase (sonst beweist er nichts).

**Test-Framework-Stack:** xUnit v3 auf Microsoft.Testing.Platform,
AwesomeAssertions, NSubstitute — Details und Projekt-Aufbau siehe
`dotnet-csharp-conventions.md` (Abschnitt Testing).

- Coverage-Ziele: Services ≥ 90 %, Integration Tests ≥ 80 %

**Anti-Pattern:** `Console.WriteLine`-"Tests" ohne Assertions, manuelle
Sichtprüfung, auskommentierte Test-Methoden, `[Fact(Skip = "...")]` ohne
Ticket.

## 5. Convention over Configuration

Sinnvolle Defaults, die nur bei echten Abweichungen überschrieben werden.

- **Namens-Konventionen**: `*Handler`, `*Service`, `*Repository`, `*Validator`
  werden automatisch per Assembly-Scanning registriert
- **Scrutor** oder **MediatR** für automatische DI-Registrierung —
  nicht jede Klasse manuell in `Program.cs` eintragen.
  **AOT-Einschränkung:** Scrutor-Scanning ist reflection-basiert und
  AOT-inkompatibel. Für AOT-Targets ist **Jab** der bevorzugte Fallback:
  ein Source-Generator-basierter DI-Container, der einem MS-DI-ähnlichen
  Attribut-Modell folgt und damit einen kurzen Migrationspfad aus
  bestehenden Scrutor/MS-DI-Projekten bietet (MIT-Lizenz,
  `pakrym/jab`). Minimales Setup:

  ```csharp
  using Jab;

  [ServiceProvider]
  [Singleton(typeof(IClock), typeof(SystemClock))]
  [Transient(typeof(IHeadingExtractor), typeof(MarkdownHeadingExtractor))]
  internal partial class AppServices { }

  // Usage
  var provider = new AppServices();
  var extractor = provider.GetService<IHeadingExtractor>();
  ```

  Pure.DI ist als Alternative zulässig für Greenfield-Projekte, die den
  Composition Root bewusst aus Clean-Architecture-Sicht neu modellieren
  wollen — dies bitte per ADR begründen.
- **Ordnerstruktur spiegelt Namespace** 1:1
- **Settings heißen** `settings.toml` (Standard), niemals `appsettings.json` in Neu-Projekten
- **Interfaces liegen neben Implementierung**, nicht in separaten `Interfaces/`-Ordnern
- **Keine `Factory`-Klassen**, wenn DI das lösen kann

Wenn Code explizite Registrierung, Konfiguration oder Mapping braucht, das
eine Convention erledigen könnte → Warnung im Review.

## 6. Settings mit Tomlyn und Live-Update

Bevorzugter Standard für Konfiguration ist **TOML** mit **Tomlyn.Extensions.Configuration**
und **`IOptionsMonitor<T>`** für Hot-Reload. TOML statt JSON, weil
Menschen die Datei lesen und von Hand editieren können sollen
(Kommentare, klare Typen, offensichtliche Sektionen).

**Standard-Setup:**

```csharp
using Tomlyn.Extensions.Configuration;

builder.Configuration.AddTomlFile(
    "settings.toml",
    optional: false,
    reloadOnChange: true);  // <-- Pflicht für Live-Update

builder.Services.Configure<MySettings>(
    builder.Configuration.GetSection("MySection"));
```

**Live-Update im Code:**

```csharp
public class MyService(IOptionsMonitor<MySettings> settings)
{
    public void DoWork()
    {
        var current = settings.CurrentValue; // immer der frische Stand
        // ...
    }
}
```

**NIEMALS** `IOptions<T>` verwenden, wenn Hot-Reload gewünscht ist —
`IOptions<T>` ist Singleton und liest den initialen Stand einmal.
**IMMER** `IOptionsMonitor<T>` für Szenarien, in denen die Anwendung ohne
Neustart umkonfiguriert werden muss.

**Validation:** `builder.Services.AddOptions<MySettings>()
.Bind(...).ValidateDataAnnotations().ValidateOnStart();` — fail-fast bei
fehlerhafter TOML.

## 7. Weitere Architektur-Leitsätze

Ergänzende Prinzipien, die in Kombination mit SOLID und Clean Architecture
gelten. Keine eigenen Kapitel, weil jeder Leitsatz knapp bleibt.

### 7.1 Vertical Slices innerhalb der Schichten

Clean Architecture definiert die **Ringe** (Domain → Application →
Infrastructure). Vertical Slices definieren die **Ordnerstruktur pro
Feature** — alle Dateien zu einem Use Case liegen zusammen:

```
src/App.Application/
  Features/
    CreateOrder/
      CreateOrderCommand.cs
      CreateOrderHandler.cs
      CreateOrderValidator.cs
      CreateOrderResult.cs
```

Kein Widerspruch zu Clean Architecture: Ringe bleiben intakt, die Ordnung
**innerhalb** der Application-Schicht folgt den Features, nicht den
technischen Kategorien (`Handlers/`, `Validators/`, `Dtos/`).

**Begründung:** Änderungen an einem Feature passieren an einem Ort,
nicht verstreut über drei Ordner. Senkt kognitive Last, macht Feature-Löschung
trivial.

### 7.2 Single Source of Truth

Jeder Fakt, jede Validierungsregel, jede Konfigurations-Entscheidung darf nur
**einmal** im System existieren.

- **Typ-Definitionen** an einer Stelle, nicht doppelt in Backend und Shared
- **Validierungsregeln** im Domain-Modell, nicht dupliziert im Controller
- **Konstanten** (Subject-Namen, Default-Werte) in einem zentralen Modul
- **Konfiguration** in `settings.toml`, nicht parallel auch in Umgebungsvariablen
  mit eigener Bedeutung

**Smell:** Wenn bei einer Regel-Änderung zwei Stellen angefasst werden müssen,
ist es eine Duplikation.

### 7.3 Event-Driven Architecture wo sinnvoll

Event-basierte Kommunikation über einen Message-Broker ist bevorzugt, wo lose Kopplung,
asynchrone Verarbeitung oder Audit-Trails gefragt sind — nicht dogmatisch
für jede Interaktion.

- **Domain Events** intern für In-Process-Reaktionen
- **Integration Events** extern über einen Message-Broker (z.B. NATS, RabbitMQ)
- **Idempotenz** ist Pflicht: Message-Handler müssen mit Duplikaten umgehen
  können (Event-ID-Deduplizierung, Upsert statt Insert)
- **Kein Event für synchrone CRUD-Operationen** — EDA ist nicht kostenlos

### 7.4 Bekannte Design Patterns bevorzugen

Wo ein etabliertes Muster passt, wird es benutzt — kein NIH-Syndrom.

- **Repository** für Persistence-Abstraktion
- **Strategy** für austauschbare Algorithmen
- **Decorator** statt Vererbung für Cross-Cutting Concerns
- **Mediator** (MediatR) für Command/Query-Dispatch
- **Factory** nur wenn DI es nicht löst
- **Options-Pattern** (`IOptionsMonitor<T>`) für Konfiguration

Neues Muster erfinden nur wenn kein etabliertes passt — und dann mit ADR
dokumentieren.

### 7.5 Composition over Inheritance

Vererbung nur für echte *is-a*-Beziehungen und stabile Hierarchien.
Für Wiederverwendung: Komposition + Interfaces bevorzugen.

- **Records** mit `with`-Expression statt Vererbungs-Ketten
- **Decorator-Pattern** statt Subclassing für Verhaltens-Erweiterung
- **Sealed by default** — Klassen werden explizit `sealed`, wenn nicht
  ausdrücklich als Basisklasse gedacht

### 7.6 Immutability by default — record, struct, readonly

Immutable Daten sind sicher, trivial zu testen und Thread-safe.

**Entscheidungsregel:**

| Typ | Wann verwenden |
|-----|----------------|
| `record` (class) | Immutable Datenhalter mit Wert-Gleichheit: DTOs, Events, Commands, Queries, Value Objects mit Referenz-Semantik |
| `readonly record struct` | Kleine Value Objects (1–3 Felder primitiver Typen, passen in ein bis zwei Maschinenregister), Positions/Koordinaten, Durations, IDs — Stack-allokiert, kein GC-Druck |
| `record struct` | Nur wenn Mutation gezielt gebraucht wird (selten) |
| `class` | Nur bei Identität, Verhalten, Lifecycle, oder wenn Vererbung/DI erforderlich |
| `struct` | Nur bei Performance-kritischen Value-Szenarien, wo `record struct` nicht passt |

**Defaults:** `init`-only Properties, `readonly` Felder, keine Setter,
Collections als `IReadOnlyList<T>`/`ImmutableArray<T>`.

**Review-Pflicht:** Jede neue `class` muss sich rechtfertigen gegenüber
`record` — wenn kein Identitäts- oder Verhaltensgrund vorliegt, ist
`record` der Default.

### 7.7 YAGNI, KISS, DRY — mit Augenmaß

Die drei klassischen Heuristiken:

- **YAGNI** (*You Ain't Gonna Need It*): keine spekulativen Features,
  keine Config-Optionen „für später", keine Abstraktion vor dem zweiten
  Anwendungsfall
- **KISS** (*Keep It Simple*): die einfachste Lösung, die funktioniert, gewinnt
- **DRY** (*Don't Repeat Yourself*): aber nicht um jeden Preis — drei
  ähnliche Zeilen sind besser als eine schlechte Abstraktion

**Balance:** YAGNI schlägt DRY, wenn Abstraktion spekulativ wäre.

### 7.8 CQS — Command-Query Separation auf Methoden-Ebene

Eine Methode ist **entweder** eine Abfrage (gibt Wert zurück, ändert keinen
Zustand) **oder** ein Command (ändert Zustand, gibt `void`/`Task` zurück).
Nie beides gleichzeitig.

```csharp
// schlecht: Query mit Seiteneffekt
public Order GetOrCreateOrder(int id) { ... }

// gut: zwei Methoden
public Order? FindOrder(int id);
public void CreateOrder(Order order);
```

CQRS ist die Architektur-Skalierung dieses Prinzips (getrennte Read- und
Write-Modelle) — wo angemessen, nicht pauschal.

### 7.9 DDD Tactical Patterns

Domain-Driven Design ist das gemeinsame Vokabular für Domänen-Modellierung:

- **Entity** — hat Identität, Lifecycle, mutable wo nötig
- **Value Object** — ohne Identität, immutable, Wert-Gleichheit (`record`!)
- **Aggregate** — Konsistenz-Grenze, Zugriff nur über Aggregate Root
- **Domain Service** — Logik, die nicht natürlich in eine Entity passt
- **Domain Event** — relevante Zustandsänderung, als Fakt formuliert
- **Bounded Context** — klare Domänengrenze, eigene Sprache, eigene Modelle
- **Ubiquitous Language** — Entwickler und Fachbereich sprechen gleich

**Konkret:** Keine Primitives dort wo Value Objects den Typ tragen
können (`OrderId` statt `int`, `Temperature` statt `double`).

## 8. Observability mit Serilog und OpenTelemetry

Software läuft oft viele Jahre im Betrieb. Ohne Observability sind
Support und Fehlersuche blind.

**Standard-Stack:**

- **Serilog** als Logging-Library — strukturiertes Logging mit
  Template-Properties, nicht String-Concatenation
- **Serilog.Sinks.Console** + **Serilog.Sinks.File** + bei Bedarf
  **Serilog.Sinks.Seq** für zentrales Log-Aggregat
- **OpenTelemetry** für Traces und Metrics
- **OpenTelemetry.Exporter.OpenTelemetryProtocol** (OTLP) für Export
  an einen zentralen Collector

**Logging-Regeln:**

```csharp
// schlecht: String-Concat, keine Struktur
_logger.LogInformation("Order " + orderId + " created for " + customer);

// gut: strukturierte Properties
_logger.LogInformation(
    "Order {OrderId} created for {Customer}",
    orderId, customer);
```

- **Niemals** `Console.WriteLine` für Logging
- **Niemals** PII/Secrets in Logs
- **Log-Level diszipliniert**: `Information` für Normalbetrieb,
  `Warning` für behebbare Anomalien, `Error` für echte Fehler,
  `Critical` nur für Ereignisse, die den Betrieb stoppen
- **Trace-Context** (TraceId, SpanId) wird durch OpenTelemetry
  automatisch mit Serilog-Ausgaben korreliert

**Metrics:**
- **Business Metrics** über `System.Diagnostics.Metrics.Meter` — werden
  von OpenTelemetry automatisch exportiert
- **Counter** für Ereignisse, **Histogram** für Verteilungen,
  **ObservableGauge** für aktuelle Zustandswerte

## 9. Debugging

### 9.1 Code-Navigation mit dem C# Language Server

Ist das `LSP`-Tool verfügbar (Plugin `csharp-lsp`), wird es für die
Navigation in C#-Code bevorzugt:

- **Go-to-Definition** und **Find References** statt Textsuche nach dem
  Symbolnamen — LSP unterscheidet gleichnamige Symbole, Überladungen und
  Namespaces, `grep` nicht
- **Hover/Typinformation**, um Typen und Signaturen zu prüfen, ohne die
  Datei komplett zu lesen
- **Diagnostics** nach Änderungen für schnelles Feedback zu
  Compiler-Fehlern und Warnungen

`grep` bleibt sinnvoll für Text, den LSP nicht kennt: Strings,
Kommentare, Konfigurationsdateien, Projekt- und Build-Dateien.
Maßgeblich für „kompiliert“ und „Tests grün“ bleiben `dotnet build` und
`dotnet test` — LSP-Diagnostics ersetzen sie nicht.

Ist das Tool nicht verfügbar oder liefert es keine Ergebnisse (z.B.
Projekt noch nicht geladen), auf `grep` und den `dotnet build`-Output
zurückfallen.

### 9.2 Bugfix-Methodik und Root-Cause-Analyse

Für Bugfixes, Analysen von Legacy-Code und CRITICAL/WARNING-Findings
gilt die **5-Why-Methodik** zur Root-Cause-Analyse: die Ursache wird
systematisch zurückverfolgt, bis sie auf eine strukturelle oder
prozessuale Ursache zeigt, nicht nur auf das sichtbare Symptom.

**Vollständige Regeln, Beispiel und Commit-Format siehe
`bugfix-tdd-first.md`** — dort ist der Bugfix-Workflow normativ
dokumentiert, inklusive 5-Why-Kette, Pflicht-Reihenfolge und
Anti-Patterns. Diese Rule hier referenziert ihn nur, um Doppelbesitz
zu vermeiden.

## Review-Checkliste (PFLICHT für Code-Reviews und Code-Analysen)

Bei Code-Reviews und Code-Analysen muss jeder Fund
einer der folgenden Kategorien zugeordnet werden:

**SOLID & Clean Code**
- [ ] SRP-Verletzung (mehrere Gründe zur Änderung in einer Klasse)
- [ ] Fehlende DI / direkte `new`-Instanzierung konkreter Typen
- [ ] Programmierung gegen konkrete Klasse statt Interface
- [ ] Magic Number / Magic String
- [ ] Funktion überschreitet 15 Zeilen oder mischt Abstraktionsebenen

**Clean Architecture**
- [ ] Framework-Abhängigkeit in Domain-Schicht
- [ ] Messaging/Event-Publishing außerhalb Infrastructure
- [ ] Verstoß gegen eine bestehende ADR ohne Begründung
- [ ] Vertical Slice zerrissen über mehrere Feature-fremde Ordner

**Typ-Design**
- [ ] `class` statt `record` ohne Identitäts- oder Verhaltensgrund
- [ ] Vererbung wo Komposition genügt hätte
- [ ] Primitives statt Value Objects (`int` statt `OrderId`)
- [ ] Mutable Collection in Public API

**Tests**
- [ ] Fehlende Tests / Coverage unter Zielwert
- [ ] Test ohne Assertion (`Console.WriteLine`, `Debug.WriteLine`)
- [ ] Test geschrieben nach der Implementierung (keine Rot-Phase)
- [ ] Feature ohne 5-Why-Analyse bei Bugfix-Kontext

**Konfiguration & Convention**
- [ ] Settings als `IOptions<T>` statt `IOptionsMonitor<T>`
- [ ] `appsettings.json` statt `settings.toml` in Neu-Projekten
- [ ] Manuelle DI-Registrierung wo Convention greifen würde
- [ ] Scrutor-Scanning in AOT-Target ohne Source-Generator-Ersatz

**Observability**
- [ ] `Console.WriteLine` oder `Debug.WriteLine` statt Serilog
- [ ] String-Konkatenation im Log statt strukturierter Properties
- [ ] PII/Secrets im Log-Output
- [ ] Fehlende Trace-Context-Korrelation

**Zeit & Threading**
- [ ] `DateTime.Now` oder `DateTime.UtcNow` statt NodaTime
- [ ] Blockierendes IO in async-fähigem Kontext
- [ ] Fehlendes `ConfigureAwait(false)` in Library-Code

**Sonstiges**
- [ ] String-Konkatenation statt `StringBuilder` in Loops
- [ ] NIH-Syndrom: eigene Lösung wo ein etabliertes Pattern passt

Jeder Fund bekommt ein Severity-Label (CRITICAL / WARNING / INFO / SUGGESTION)
und einen Begründungssatz, der auf das verletzte Prinzip verweist.
