# Providers and Resources

Terraform core is deliberately ignorant. Everything
it can manage arrives through a **provider**: a
plugin program that understands one platform's API
and translates between Terraform's world (resources
with arguments and attributes) and the platform's
world (API calls). The AWS provider knows thousands
of resource types; the `local` provider used here
knows a handful, including `local_file`. When you
read `resource "local_file" "pages"`, the first
label is the resource *type*, and its prefix
before the first underscore names the provider:
`local`.

Providers are published in the
[Terraform Registry](https://registry.terraform.io),
each with documentation for every resource and data
source it offers. Reading a provider's registry
pages is most of real-world Terraform work.

## Declaring what you need

A configuration states its providers, with version
constraints, in a `terraform` block. The example's:

```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
```

- `source` is the registry address:
  *namespace/name*. `hashicorp/` is HashiCorp's own
  namespace; third-party providers live under their
  authors' names.
- `version` is a constraint, not necessarily a
  pin.
  `~> 2.5` — the *pessimistic* constraint — means
  "2.5 or newer, but below 3.0": bug fixes and
  minor releases yes, breaking changes no. Other
  forms: `>= 1.0`, `= 2.9.1` for an exact pin.

Pin something, always. An unpinned provider can
change under you between two runs of the same
configuration.

## terraform init: fetch and lock

Nothing works until `terraform init` has downloaded
the providers (and modules) the configuration
requires. Real output, abridged:

```
$ terraform init
Initializing the backend...

Initializing modules...
- note in modules/note

Initializing provider plugins...
- Finding hashicorp/local versions matching "~> 2.5"...
- Finding hashicorp/random versions matching "~> 3.6"...
- Finding hashicorp/null versions matching "~> 3.2"...
- Installing hashicorp/random v3.9.1...
- Installed hashicorp/random v3.9.1 (signed by HashiCorp)
- Installing hashicorp/null v3.3.2...
- Installed hashicorp/null v3.3.2 (signed by HashiCorp)
- Installing hashicorp/local v2.9.1...
- Installed hashicorp/local v2.9.1 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
...
Terraform has been successfully initialized!
```

What init did:

- Resolved the constraints against the registry and
  installed exact versions: **local 2.9.1,
  random 3.9.1, null 3.3.2** — `~> 3.6` allowing
  3.9.1 is the pessimistic constraint doing its
  job.
- Verified the downloads against HashiCorp's
  signatures ("signed by HashiCorp").
- Wrote `.terraform.lock.hcl`, recording the exact
  versions and their hashes, one block per
  provider:

```hcl
provider "registry.terraform.io/hashicorp/local" {
  version     = "2.9.1"
  constraints = "~> 2.5"
  hashes = [
    "h1:qGLHCuYSus+uHNnoEL4SuJqOs5yrNOcB7gnuHoVqizo=",
    # ...further hashes elided
  ]
}
```

**Commit the lock file.** It is what makes a
teammate's (or CI's) init install bit-identical
providers instead of re-resolving "newest allowed"
on the day. Change versions deliberately:
`terraform init -upgrade` re-resolves within your
constraints and rewrites the lock.

Downloads land in a `.terraform/` directory in the
project — generated, platform-specific, and never
committed. Re-running init after changing
`required_providers` or adding a module is normal
and cheap.

**Check:** `terraform providers` shows the tree of
what the configuration requires, module included —
also from the real run:

```
$ terraform providers

Providers required by configuration:
.
├── provider[registry.terraform.io/hashicorp/null] ~> 3.2
├── provider[registry.terraform.io/hashicorp/local] ~> 2.5
├── provider[registry.terraform.io/hashicorp/random] ~> 3.6
└── module.note
    └── provider[registry.terraform.io/hashicorp/local] ~> 2.5
```

## Resources, and their read-only cousins

A **resource** is one managed object: a file, a
server, a DNS record. A provider also offers
**data sources** — read-only lookups that fetch
information during planning and create nothing.
The example reads an existing file with one:

```hcl
data "local_file" "banner" {
  filename = "${path.module}/banner.txt"
}
```

Resources get the next chapters; data sources are
treated fully in Expressions and Repetition. One
habit starts here: when a provider behaves in a
way you didn't expect, the answer is in its
registry documentation for that resource — down to
which arguments force replacement when changed,
which will matter in the Worked Example.
