# Api Manifest

This manifest contains the file structure and content for the api components.

## api/openapi.yaml

```yaml
openapi: 3.0.3
info:
  title: Sample Service
  version: 0.1.0
paths:
  /v1/health:
    get:
      summary: Liveness/health
      responses:
        "200":
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  status: { type: string, enum: [ok] }

```

---

## app-api/AppApi.sln

```xml
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "AppApi.Web", "src/AppApi.Web/AppApi.Web.csproj", "{00000001-0000-0000-0000-000000000001}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "AppApi.Application", "src/AppApi.Application/AppApi.Application.csproj", "{00000002-0000-0000-0000-000000000002}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "AppApi.Domain", "src/AppApi.Domain/AppApi.Domain.csproj", "{00000003-0000-0000-0000-000000000003}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "AppApi.Infrastructure", "src/AppApi.Infrastructure/AppApi.Infrastructure.csproj", "{00000004-0000-0000-0000-000000000004}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "UnitTests", "tests/UnitTests/UnitTests.csproj", "{00000005-0000-0000-0000-000000000005}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "ArchitectureTests", "tests/ArchitectureTests/ArchitectureTests.csproj", "{00000006-0000-0000-0000-000000000006}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "IntegrationTests", "tests/IntegrationTests/IntegrationTests.csproj", "{00000007-0000-0000-0000-000000000007}"
EndProject
Global
EndGlobal

```

---

## app-api/src/AppApi.Web/Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
var app = builder.Build();
app.MapGet("/v1/health", () => Results.Json(new { status = "ok" }));
app.Run();
public partial class Program { }

```

---

## app-api/src/AppApi.Web/AppApi.Web.csproj

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\AppApi.Application\AppApi.Application.csproj" />
  </ItemGroup>
</Project>

```

---

## app-api/src/AppApi.Application/AppApi.Application.csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\AppApi.Domain\AppApi.Domain.csproj" />
  </ItemGroup>
</Project>

```

---

## app-api/src/AppApi.Domain/AppApi.Domain.csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>

```

---

## app-api/src/AppApi.Infrastructure/AppApi.Infrastructure.csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="8.0.4" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\AppApi.Domain\AppApi.Domain.csproj" />
  </ItemGroup>
</Project>

```

---

## app-api/tests/ArchitectureTests/ArchitectureTests.csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageReference Include="NetArchTest.Rules" Version="1.3.0" />
    <PackageReference Include="xunit" Version="2.7.0" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.7" />
  </ItemGroup>
</Project>

```

---

## app-api/tests/ArchitectureTests/LayeringTests.cs

```csharp
using NetArchTest.Rules;
using Xunit;
namespace AppApi.ArchitectureTests;
public class LayeringTests
{
    [Fact]
    public void Domain_must_be_pure()
    {
        var r = Types.InCurrentDomain()
          .That().ResideInNamespace("AppApi.Domain")
          .Should().NotHaveDependencyOnAny(new[] { "AppApi.Infrastructure", "AppApi.Application", "AppApi.Web", "Microsoft.EntityFrameworkCore" })
          .GetResult();
        Assert.True(r.IsSuccessful, r.FailingTypeNames != null ? string.Join("\n", r.FailingTypeNames) : "");
    }
    [Fact]
    public void Application_must_not_depend_on_Web_or_Infrastructure()
    {
        var r = Types.InCurrentDomain()
          .That().ResideInNamespace("AppApi.Application")
          .Should().NotHaveDependencyOnAny(new[] { "AppApi.Web", "AppApi.Infrastructure" })
          .GetResult();
        Assert.True(r.IsSuccessful, r.FailingTypeNames != null ? string.Join("\n", r.FailingTypeNames) : "");
    }
    [Fact]
    public void Web_must_not_reference_EFCore()
    {
        var r = Types.InCurrentDomain()
          .That().ResideInNamespace("AppApi.Web")
          .Should().NotHaveDependencyOn("Microsoft.EntityFrameworkCore")
          .GetResult();
        Assert.True(r.IsSuccessful, r.FailingTypeNames != null ? string.Join("\n", r.FailingTypeNames) : "");
    }
}

```

---

## app-api/tests/UnitTests/UnitTests.csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <IsPackable>false</IsPackable>
    <CollectCoverage>true</CollectCoverage>
    <Threshold>80</Threshold>
    <ThresholdType>line</ThresholdType>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="FluentAssertions" Version="8.6.0" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <ProjectReference Include="..\..\src\AppApi.Application\AppApi.Application.csproj" />
    <PackageReference Include="coverlet.msbuild" Version="6.0.0" />
    <PackageReference Include="xunit" Version="2.7.0" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.7" />
  </ItemGroup>
</Project>

```

---

## app-api/tests/UnitTests/SampleTests.cs

```csharp
using Xunit;using FluentAssertions;namespace AppApi.UnitTests;public class SampleTests{[Fact]public void Red_to_Green_example(){var sum=1+1;sum.Should().Be(2);}}

```

---

## app-api/tests/IntegrationTests/IntegrationTests.csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\..\src\AppApi.Web\AppApi.Web.csproj" />
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="8.0.8" />
    <PackageReference Include="xunit" Version="2.7.0" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.7" />
  </ItemGroup>
</Project>

```

---

## app-api/tests/IntegrationTests/HealthTests.cs

```csharp
using System.Net;using Microsoft.AspNetCore.Mvc.Testing;using Xunit;public class HealthTests: IClassFixture<WebApplicationFactory<Program>>{private readonly HttpClient _client;public HealthTests(WebApplicationFactory<Program> factory)=>_client=factory.CreateClient();[Fact]public async Task Health_returns_ok(){var res=await _client.GetAsync("/v1/health");Assert.Equal(HttpStatusCode.OK,res.StatusCode);}}

```

