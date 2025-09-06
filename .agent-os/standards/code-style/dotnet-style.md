# .NET/C# Code Style — Microsoft‑sourced Standard (Agent‑OS: `standards/code-style.md`)

> **Scope:** C#/.NET repositories.  
> **Source of truth:** Microsoft Learn (links included below).  
> **How to enforce:** Use `.editorconfig` with .NET code‑style analyzers (IDExxxx).

---

## 1) Principles (from Microsoft guidance)

- Use **.editorconfig** to encode style so IDE and CI enforce it consistently.  
- Prefer **clear, descriptive names**; follow the **Framework Design Guidelines** for naming and capitalization.  
- Treat style rules as **analyzers**; set severities so CI can block merges when needed.

---

## 2) Quick rules (human‑readable)

- **Naming**
  - PascalCase: **types, methods, properties, events, namespaces**.
  - camelCase: **locals, parameters**.
  - Interfaces **start with `I`** (e.g., `IService`).  
  - Attributes **end with `Attribute`** (e.g., `SerializableAttribute`).  
  - Enum type names: **singular** (plural only for `[Flags]`).  
- **Formatting**
  - Keep consistent newlines/braces/spacing via IDE formatting (IDE0055).  
  - Prefer **file‑scoped namespaces** (C# 10+) for files containing one namespace.  
- **Style preferences**
  - Use `var` when type is apparent or built‑in; otherwise explicit type.  
  - Prefer **object/collection initializers**, **`using` declarations**, and **null‑propagation**.  
  - Avoid `this.` qualification except when needed for clarity.  
- **Project hygiene**
  - Keep one formatter + one analyzer set; do not mix overlapping tools.  
  - Make style warnings visible (warning or error) in CI.

---

## 3) Drop‑in `.editorconfig` (Microsoft options)

> Put this at the repo root. Adjust namespaces and severities to taste.

```ini
# .editorconfig (C# / .NET)
root = true

[*.{cs,vb}]

# Treat style & naming as analyzer warnings (can raise to 'error')
dotnet_analyzer_diagnostic.category-Style.severity = warning
dotnet_analyzer_diagnostic.category-Naming.severity = warning

########################################
# Naming rules (Microsoft Learn patterns)
# https://learn.microsoft.com/dotnet/fundamentals/code-analysis/style-rules/naming-rules
########################################

# Symbols
dotnet_naming_symbols.public_members.applicable_kinds = class,struct,interface,enum,delegate,property,method,field,event
dotnet_naming_symbols.public_members.applicable_accessibilities = public, protected, protected_internal

dotnet_naming_symbols.private_fields.applicable_kinds = field
dotnet_naming_symbols.private_fields.applicable_accessibilities = private

dotnet_naming_symbols.interfaces.applicable_kinds = interface
dotnet_naming_symbols.interfaces.applicable_accessibilities = *

# Styles
dotnet_naming_style.pascal_case.capitalization = pascal_case
dotnet_naming_style.camel_case.capitalization = camel_case
dotnet_naming_style._camel_case.capitalization = camel_case
dotnet_naming_style._camel_case.required_prefix = _
dotnet_naming_style.interface_with_i.capitalization = pascal_case
dotnet_naming_style.interface_with_i.required_prefix = I

# Rules
dotnet_naming_rule.public_members_should_be_pascal_case.symbols = public_members
dotnet_naming_rule.public_members_should_be_pascal_case.style = pascal_case
dotnet_naming_rule.public_members_should_be_pascal_case.severity = warning

dotnet_naming_rule.private_fields_should_be__camelCase.symbols = private_fields
dotnet_naming_rule.private_fields_should_be__camelCase.style = _camel_case
dotnet_naming_rule.private_fields_should_be__camelCase.severity = warning

dotnet_naming_rule.interfaces_should_start_with_I.symbols = interfaces
dotnet_naming_rule.interfaces_should_start_with_I.style = interface_with_i
dotnet_naming_rule.interfaces_should_start_with_I.severity = warning

########################################
# Code style rule options
# https://learn.microsoft.com/dotnet/fundamentals/code-analysis/code-style-rule-options
########################################

# Qualification
dotnet_style_qualification_for_field = false:suggestion
dotnet_style_qualification_for_property = false:suggestion
dotnet_style_qualification_for_method = false:suggestion
dotnet_style_qualification_for_event = false:suggestion

# Prefer 'var' where appropriate
csharp_style_var_for_built_in_types = true:suggestion
csharp_style_var_when_type_is_apparent = true:suggestion
csharp_style_var_elsewhere = false:suggestion

# Language constructs
dotnet_style_object_initializer = true:suggestion
dotnet_style_collection_initializer = true:suggestion
dotnet_style_prefer_auto_properties = true:suggestion
dotnet_style_null_propagation = true:suggestion
dotnet_style_prefer_is_null_check_over_reference_equality_method = true:suggestion
csharp_prefer_simple_using_statement = true:suggestion

########################################
# Namespace style (file‑scoped vs block‑scoped)
# https://learn.microsoft.com/dotnet/fundamentals/code-analysis/style-rules/ide0160-ide0161
########################################
csharp_style_namespace_declarations = file_scoped:suggestion

########################################
# Formatting (IDE0055 governs all formatting options)
# https://learn.microsoft.com/dotnet/fundamentals/code-analysis/style-rules/ide0055
# C# formatting options: https://learn.microsoft.com/dotnet/fundamentals/code-analysis/style-rules/csharp-formatting-options
########################################

# Braces/new lines
csharp_new_line_before_open_brace = all
csharp_new_line_between_query_expression_clauses = true

# Indentation & whitespace
indent_style = space
indent_size = 4
end_of_line = crlf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

---

## 4) Rationale + links for LLMs (cite Microsoft)

- **C# coding conventions (naming, layout, examples).**  
  Source: Microsoft Learn — *Common C# code conventions*.
- **.editorconfig as the configuration mechanism for style analyzers.**  
  Source: Microsoft Learn — *.NET code style rule options*.
- **Naming conventions & how to encode them in `.editorconfig`.**  
  Source: Microsoft Learn — *Code‑style naming rules*.
- **Formatting controlled by IDE0055, with C#‑specific options.**  
  Sources: Microsoft Learn — *IDE0055 Fix formatting* and *C# formatting options*.
- **File‑scoped namespaces preference (C# 10+).**  
  Sources: Microsoft Learn — *File‑scoped namespaces* (spec) and *IDE0160/IDE0161*.
- **General naming & capitalization (Framework Design Guidelines).**  
  Sources: Microsoft Learn — *General naming conventions*, *Names of classes/structs/interfaces*, *Names of type members*.

---

## 5) Definition of Done (style)

- `.editorconfig` present at repo root.  
- Solution builds **without** style or naming warnings (or justified suppressions).  
- New code uses file‑scoped namespaces (unless multiple namespaces per file).  
- CI enforces format (IDE0055) and style rules.
