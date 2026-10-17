# Variables and Outputs

A configuration with hard-coded values is a script
that works once. **Variables** are its inputs —
declared once, given values per run — and
**outputs** are what it reports back. Together
they turn a pile of `.tf` files into a reusable
thing with a defined interface, which is also
exactly how modules (next-but-one chapter) talk to
their callers.

## Declaring variables

From the example's `variables.tf`:

```hcl
variable "environment" {
  description = "Deployment label used in the generated file names."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "copies" {
  description = "How many identical build stamps to write."
  type        = number
  default     = 2

  validation {
    condition     = var.copies >= 1 && var.copies <= 5
    error_message = "copies must be between 1 and 5."
  }
}
```

- `type` — `string`, `number`, `bool`, collections
  (`list`, `set`, `map`), or structured `object`
  types. Terraform converts when it safely can and
  errors when it can't.
- `default` — makes the variable optional. No
  default means the caller *must* supply a value.
- `description` — documentation for whoever fills
  it in; treat it as part of the interface.
- `validation` — a condition the value must pass,
  with your own error message. Cheap insurance,
  caught before anything is planned.

Validation earning its keep, from a real run:

```
$ terraform plan -var environment=qa
...
Error: Invalid value for variable

  on variables.tf line 1:
   1: variable "environment" {
    ├────────────────
    │ var.environment is "qa"

environment must be dev, staging, or prod.

This was checked by the validation rule at variables.tf:6,3-13.
```

The run exits non-zero having changed nothing.
Fail early, fail in words you wrote.

## Supplying values

In descending order of precedence (later sources
win): defaults; a `terraform.tfvars` file (or
`*.auto.tfvars`); `-var-file` for a named file;
`-var name=value` flags; and `TF_VAR_name`
environment variables. The convention this guide
follows: ship a `terraform.tfvars.example` in the
repo, copy it to `terraform.tfvars` locally, and
keep the real file out of Git — values files are
where secrets wander in. The example's:

```hcl
environment = "dev"
message     = "Deployed by hand the first time."
copies      = 2
page_names  = ["index", "about"]
```

## Outputs: what the configuration reports

Outputs are declared with a value and, optionally,
`sensitive = true`. From the example's
`outputs.tf`, the plain ones are readable in the
Plan and Apply chapters; the interesting two:

```hcl
output "settings" {
  description = "The settings snapshot stored by the terraform_data resource."
  value       = terraform_data.settings.output
}

output "admin_token" {
  description = "Generated admin token. Sensitive on purpose, so Terraform hides it in normal output."
  value       = random_password.admin_token.result
  sensitive   = true
}
```

After apply, `terraform output` prints them all —
objects expanded, sensitive values redacted:

```
$ terraform output
admin_token=<redacted>
banner_sha256 = "7a509ab4f7bc8f42619a533e43bdfa0a94c7d904b06aa50d45e9e900e69973a1"
generated_files = [
  "./out/dev-about.txt",
  "./out/dev-index.txt",
]
note_file = "./out/note.txt"
server_name = "correct-dane"
settings = {
  "environment" = "dev"
  "message" = "Deployed by hand the first time."
  "pages" = tolist([
    "about",
    "index",
  ])
}
```

Three facts about outputs to internalise:

- **They live in state.** Anything that can read
  the state can read the outputs — see the State
  chapter's plain-text warning.
- **Sensitive is a display rule,** not storage
  protection. `terraform output -raw admin_token`
  prints the token to whoever runs it; the lab
  verified it is 16 characters long *without*
  printing it (`| wc -c`). If a value must never
  be retrievable, it must never be an output —
  and arguably never generated into state at all.
- **Outputs are an API.** Other tooling — scripts,
  pipelines, other configurations via remote-state
  data sources **(documented)** — reads them with
  `terraform output -json`. Name and type them
  like you mean it.
