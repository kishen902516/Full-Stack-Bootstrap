## 22) Import-Rule Snippets (FE/DB add-ons)

**dependency-cruiser (FE layers)**
```js
// Extend .dependency-cruiser.js
{
  name: "ui-only-inward",
  severity: "error",
  from: { path: "^src/ui" },
  to:   { path: "^src/(adapters|application|domain)" }
},
{
  name: "no-ui-from-lower-layers",
  severity: "error",
  from: { path: "^src/(domain|application|adapters)" },
  to:   { path: "^src/ui" }
}
```

**ArchUnit (Java repos touching DB)**
```java
// Repositories implement domain ports in infrastructure only
ArchRule reposImplementPorts = ArchRuleDefinition.classes()
  .that().resideInAPackage("..infrastructure.persistence..")
  .and().areAnnotatedWith(org.springframework.stereotype.Repository.class)
  .should().dependOnClassesThat().resideInAPackage("..domain..");

// Domain has no ORM deps
ArchRule domainHasNoOrm = ArchRuleDefinition.noClasses()
  .that().resideInAPackage("..domain..")
  .should().dependOnClassesThat().resideInAnyPackage("org.hibernate..", "jakarta.persistence..");
```

**NetArchTest (.NET)**
```csharp
// Domain has no EF Core references
var noEfInDomain = Types.InCurrentDomain()
  .That().ResideInNamespace("MyApp.Domain", true)
  .Should().NotHaveDependencyOnAny("Microsoft.EntityFrameworkCore", "System.Data")
  .GetResult();
Assert.True(noEfInDomain.IsSuccessful, noEfInDomain.GetFailingTypes());
```

---
[⬅ Back to Master Index](./best-practices.index.md)
