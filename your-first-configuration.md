# Your First Configuration

A Terraform **configuration** is a directory of
files ending in `.tf`. There is no single "main
file" as far as the tool is concerned — every
`.tf` file in the directory is read together —
but humans organise them by convention:
`main.tf` (providers and resources), `variables.tf`
(inputs), `outputs.tf` (results). The example
project shipped with this guide, in `examples/`,
follows that layout, and everything quoted in the
next several chapters comes from running it.

## Installing Terraform

Terraform is a single static binary. The official
route **(documented for your machine; the build
lab used the direct download)** is
[developer.hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install):
a zip per platform from
`releases.hashicorp.com`, plus packages for common
Linux distributions and Homebrew on macOS. On
Windows it is the same binary in a zip; add its
folder to your `PATH`.

The lab machine used the zip route, verifying the
download against HashiCorp's published SHA-256
sums. Check afterwards:

```
$ terraform version
Terraform v1.16.6
on linux_amd64
```

Version managers such as `tfenv` exist if you
juggle several Terraform versions; for learning,
one current binary is enough.

## The anatomy of the language

The language is called **HCL** (HashiCorp
Configuration Language). Almost everything in it
is a **block**: a type, some labels, and a body in
braces.

```hcl
resource "random_pet" "server" {
  length = 2
}
```

- `resource` — the block type. Others you will
  meet: `variable`, `output`, `provider`,
  `module`, `data`, `locals`, `terraform`.
- `"random_pet"` and `"server"` — labels. For a
  resource they are the *type* (supplied by a
  provider) and the *name* (yours). Together they
  form the resource's address:
  `random_pet.server`.
- Inside the braces are **arguments**:
  `length = 2` sets an input the provider accepts.

Each resource also has **attributes** — values the
provider reports back after creating it, like
`random_pet.server.id` (the generated name
itself). Arguments are what you set; attributes
are what you get. Other blocks refer to attributes
with dotted expressions:

```hcl
content = "Server: ${random_pet.server.id}"
```

The `${ ... }` inside a string is an
**expression** being interpolated; outside strings,
expressions are written bare
(`count = var.copies`). Expressions are a chapter
of their own (Expressions and Repetition); the
important idea now is that any value in a
configuration can be computed from other values,
and Terraform works out the dependency order
itself.

Other small facts of the language:

- Comments start with `#` or `//`; `/* ... */`
  also works.
- Strings can span lines with a *heredoc*:
  `<<-EOT` … `EOT`, used by the example to build
  file contents.
- There are no semicolons, and trailing commas are
  mostly not a thing. The formatter (below) will
  keep you honest.

## terraform fmt keeps it uniform

HCL has one canonical layout — aligned `=` signs,
two-space indentation — and `terraform fmt`
rewrites files into it. On the example project,
one variable block had been written with unaligned
arguments. Running `terraform fmt -diff` printed
exactly what it fixed (and applied the fix —
`-diff` shows the diff, it does not suppress the
write):

```
$ terraform fmt -diff
variables.tf
--- old/variables.tf
+++ new/variables.tf
@@ -11,8 +11,8 @@

 variable "message" {
   description = "Line written into every generated page."
-  type = string
-  default = "Deployed by hand the first time."
+  type        = string
+  default     = "Deployed by hand the first time."
 }
```

Plain `terraform fmt` prints the name of each file
it rewrote, and nothing when everything is already
formatted. `terraform fmt -check` exits non-zero
if any file needs formatting — the form CI
pipelines use. The shipped example files pass
`-check -recursive` (which also descends into the
module directory).

**Check:** your installation prints a version,
and you can point at a block and name its type,
labels, arguments, and one attribute. Next, the
plugins that make blocks mean something:
providers.
