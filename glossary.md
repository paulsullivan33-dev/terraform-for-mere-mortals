# Glossary

**Apply** — the step that executes a plan:
creating, updating, and deleting real things
until they match the configuration.

**Argument** — an input you set inside a block,
as in `length = 2`. Compare *attribute*.

**Attribute** — a value a resource or data
source exposes after it exists, like
`random_pet.server.id`. Compare *argument*.

**Backend** — the configured place where state
is stored: a local file by default, or a remote
service for shared work.

**Block** — HCL's unit of structure: a type,
optional labels, and a body in braces.

**Configuration** — the `.tf` files in a
directory, read together as one declaration of
desired state.

**count** — a resource meta-argument that makes
N numbered instances: `stamp[0]`, `stamp[1]`, …

**Data source** — a read-only lookup performed
during planning. It creates nothing; it fetches
facts about things that already exist.

**Declarative** — describing the end state and
letting the tool work out the steps, as opposed
to scripting the steps themselves.

**Destroy** — the inverse of apply: delete
everything the state tracks, after a plan of its
own.

**Drift** — divergence between the configuration
and reality caused by changes made outside
Terraform, discovered at refresh time.

**Expression** — anything that computes a value:
a reference, a function call, a conditional, an
interpolation inside a string.

**for_each** — a resource meta-argument that
makes one instance per element of a set or map,
addressed by key: `pages["index"]`.

**Forces replacement** — a plan note meaning a
changed attribute cannot be edited in place; the
provider will destroy and recreate the resource.
The provider decides, per attribute.

**HCL** — HashiCorp Configuration Language, the
syntax of `.tf` files.

**Idempotent** — safe to repeat: applying the
same configuration twice changes nothing the
second time.

**Import** — adopting an existing, unmanaged
object into state so Terraform can manage it
from then on, without recreating it.

**Infrastructure as code** — the practice of
defining infrastructure in files that can be
reviewed, versioned, and re-applied.

**Known after apply** — a plan's way of saying a
value cannot exist yet (it depends on something
the apply itself will generate).

**Local value (local)** — a named expression
inside a module, computed once and referenced
by name.

**Lock file** — `.terraform.lock.hcl`: the exact
provider versions and hashes `init` selected.
Commit it.

**Module** — a folder of configuration with
variables in and outputs out, callable like a
function. The directory you run Terraform in is
the *root module*.

**null_resource** — a resource from the `null`
provider that manages nothing itself; used with
triggers and provisioners to run behaviour "when
this changes".

**Output** — a named value a configuration
reports after apply; the interface other tooling
reads back.

**Plan** — the computed difference between
configuration and (refreshed) reality, printed
for approval before anything changes.

**Provider** — a plugin that teaches Terraform
one platform's API: AWS, a DNS host, the local
filesystem.

**Provisioner** — a hook that runs a command or
copies files when a resource is created (or
destroyed). A last resort; most configuration
belongs in arguments, not scripts.

**Refresh** — Terraform re-reading the real
objects behind its state, at the start of every
plan, so the diff is against now, not memory.

**Registry** — registry.terraform.io, the public
catalogue of providers and shared modules.

**Replacement** — destroy-then-create of one
resource, shown as `-/+` in a plan.

**Resource** — one managed object declared in a
configuration: a file, a server, a record.

**Sensitive** — a marking on variables and
outputs that hides values from console output.
It does not encrypt anything; state still stores
the value in plain text.

**State** — Terraform's record of what it
manages: resource addresses mapped to real IDs
and last-known attributes. The basis of every
plan.

**Target** — `-target=ADDRESS`, restricting an
operation to one resource and its dependencies.
An emergency tool.

**terraform_data** — a resource built into
Terraform itself (no provider) that stores a
value in state; useful for snapshots and for
triggering behaviour on change.

**tfvars** — `terraform.tfvars` and friends:
files assigning values to variables for a run.

**Trigger** — a value stored on a
`null_resource`; when it changes, the resource
is replaced and its provisioners re-run.

**Variable** — a declared input to a
configuration or module, with a type, an
optional default, and optional validation.

**Workspace** — a named, separate state for the
same configuration. A way to run one
configuration several times; most teams
eventually prefer separate configurations.
