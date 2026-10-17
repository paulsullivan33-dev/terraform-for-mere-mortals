# Expressions and Repetition

Static values make static infrastructure. The
working parts of real configurations are
**expressions** — values computed from variables,
attributes, and functions — and two meta-arguments
that stamp out copies: `count` and `for_each`.
This chapter runs everything through the example
project and `terraform console`, which evaluates
expressions interactively against the current
configuration.

## Functions and conditionals, evaluated for real

Expressions were typed into `terraform console`
with the example's own values in force
(`environment = "dev"`, `copies = 2`,
`page_names = ["index", "about"]`). Results are
verbatim:

```
> format("%s-%s", var.environment, "index")
"dev-index"
> var.copies > 2 ? "many" : "few"
"few"
> lookup({ dev = "small", prod = "large" }, var.environment, "unknown")
"small"
> merge({ a = 1 }, { b = 2 })
{
  "a" = 1
  "b" = 2
}
> upper(join(",", sort(tolist(var.page_names))))
"ABOUT,INDEX"
```

- `format()` builds strings with `%s`-style verbs
  — though plain interpolation
  (`"${var.environment}-${each.key}"`, which is
  what the example's filenames use) is usually
  clearer.
- The **conditional** `condition ? a : b` picks a
  value. It is how "small in dev, large in prod"
  gets said without branching code.
- `lookup(map, key, default)` reads a map safely.
- `merge()` combines maps — the standard trick
  for layering default tags over per-resource
  ones in cloud configurations.
- Functions compose: `sort`, `tolist`, `join`,
  `upper` chained into one line. The example also
  runs `trimspace()` (on the banner file's
  contents), `sha256()` (hashing page contents
  for the build-log trigger), and `contains()`
  (in the variable validation).

There are a hundred more functions; the
[official function reference](https://developer.hashicorp.com/terraform/language/functions)
is the complete list. Learn the ten you keep
reaching for; look the rest up.

## count: N copies, numbered

```hcl
resource "local_file" "stamp" {
  count = var.copies

  filename = "${path.module}/out/stamp-${count.index}.txt"
  content  = "build ${random_id.build.hex}\n"
}
```

`count` creates that many instances, addressed
`local_file.stamp[0]`, `[1]`, … with `count.index`
available inside. It suits "this many identical
things". Its weakness: instances are known by
*position*, so removing the middle of a list
renumbers the rest and Terraform plans churn
against items you didn't touch.

## for_each: copies with names

```hcl
resource "local_file" "pages" {
  for_each = var.page_names

  filename = "${path.module}/out/${var.environment}-${each.key}.txt"
  content  = <<-EOT
    ${local.banner_line}
    Page: ${each.key}
    ...
  EOT
}
```

`for_each` iterates a set or map; instances are
addressed by key — `local_file.pages["index"]` —
and `each.key` / `each.value` are available
inside. Adding or removing a name touches only
that instance. **Rule of thumb:** `for_each` for
anything with identity, `count` for a pure number
of interchangeable copies.

## locals: name a computation once

```hcl
locals {
  banner_line = trimspace(data.local_file.banner.content)
}
```

A **local value** is a named expression, usable
anywhere in the module. Use locals when a
computation repeats or deserves a name; don't
turn them into a junk drawer — every local is
another hop when reading the configuration later.

## Data sources: reading what you don't manage

A **data source** asks a provider to *read*
something at plan time. The example reads a file
that ships with the project:

```hcl
data "local_file" "banner" {
  filename = "${path.module}/banner.txt"
}
```

The plan shows the read happening, and values
derived from it are known immediately — this is
why the banner's checksum appeared, fully
computed, in the very first plan's outputs:

```
data.local_file.banner: Reading...
data.local_file.banner: Read complete after 0s [id=db86c0bfa3387a3ea77846944ec3a07490fbd1c9]
...
+ banner_sha256 = "7a509ab4f7bc8f42619a533e43bdfa0a94c7d904b06aa50d45e9e900e69973a1"
```

Data sources are how configurations consume the
outside world: the current cloud account, an
existing network, another project's outputs.
Two cautions: a data source that can't be read
fails the plan, and anything read is recorded in
state (the State chapter's secrecy rules apply).
