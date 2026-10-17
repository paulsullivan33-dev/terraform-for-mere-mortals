# Modules

A **module** is a folder of configuration treated
as one unit: it takes variables in, manages some
resources inside, and exposes outputs. Every
configuration is already a module (the *root*
module); splitting pieces into *child* modules is
how configurations stay readable and how a pattern
gets reused in ten projects without copy-paste.

Think function, not library: a module call passes
arguments and receives return values, and the
internals are the module's own business.

## A small module, complete

The example's `modules/note/` is a single
`main.tf` that writes one formatted text file.
Its whole interface is three variables and two
outputs:

```hcl
variable "title" {
  description = "First line of the note."
  type        = string
}

variable "body" {
  description = "Body text of the note."
  type        = string
}

variable "directory" {
  description = "Directory the note file is written into."
  type        = string
}

resource "local_file" "note" {
  filename = "${var.directory}/note.txt"
  content  = "${var.title}\n\n${var.body}\n"
}

output "file_path" {
  description = "Path of the written note file."
  value       = local_file.note.filename
}

output "checksum" {
  description = "SHA-256 of the note file's content."
  value       = local_file.note.content_sha256
}
```

No defaults on those variables: a caller *must*
say what the note is. Defaults are how a module
expresses "sensible unless you care" — their
absence expresses "no sensible value exists".

## Calling it

```hcl
module "note" {
  source = "./modules/note"

  title     = "Release note"
  body      = "Environment ${var.environment} deployed on ${random_pet.server.id}."
  directory = "${path.module}/out"
}
```

- `source` — where the module lives. A relative
  path for a local folder, as here; a registry
  address or Git URL for shared ones
  **(documented)**.
- The remaining arguments are the module's
  variables, by name. Misspell one and validation
  complains before anything runs.
- The module's outputs come back as attributes:
  the root configuration's `note_file` output is
  literally `module.note.file_path`.

Modules are installed by `init`, like providers —
the real init output in the Providers chapter
included the line `- note in modules/note`. Change
a module's `source` and you re-run init.

## What changes once modules are involved

**Addresses grow prefixes.** The note file is
`module.note.local_file.note` in plans and
`terraform state list` — you saw exactly that in
the State chapter. Nested modules nest prefixes.

**Providers flow downhill.** A child module uses
the providers its caller configured unless it
declares its own requirements; the example's
module needs `local`, and the providers tree
(Providers chapter) shows it nested under
`module.note`.

**State stays singular.** Modules organise code,
not state: one project, one state, however many
modules. Splitting a project into several *root*
modules with separate states is a different,
bigger decision — usually made per environment or
per team boundary.

## Registry modules **(documented)**

The Terraform Registry hosts thousands of shared
modules — whole VPCs, Kubernetes clusters,
database setups — versioned like providers and
pinned the same way. They are genuinely how most
cloud Terraform gets written. They are also other
people's opinions at scale: read what a registry
module creates before applying it, pin its
version, and remember that a module you can't
explain is infrastructure you don't control. The
local module above was run for this guide; no
registry module was.
