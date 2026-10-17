# Plan and Apply

Everything in Terraform orbits one loop:

```
write  →  plan  →  read the plan  →  apply  →  reality matches
  ↑                                                     │
  └─────────────  change something, repeat  ────────────┘
```

## plan: the diff, before anything moves

`terraform plan` changes nothing. It **refreshes**
its picture of reality (asking each provider "what
does this object look like now?"), reads data
sources, compares the result with your
configuration, and prints the difference as a list
of proposed actions. The example's first plan
begins:

```
$ terraform plan
data.local_file.banner: Reading...
data.local_file.banner: Read complete after 0s [id=db86c0bfa3387a3ea77846944ec3a07490fbd1c9]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.pages["about"] will be created
  + resource "local_file" "pages" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      # ...further checksum attributes elided
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./out/dev-about.txt"
      + id                   = (known after apply)
    }
```

The symbols are the whole vocabulary of change:

| Symbol | Meaning |
| --- | --- |
| `+` | create — this will be made |
| `-` | destroy — this will be deleted |
| `~` | update in place — same object, changed attributes |
| `-/+` | destroy then recreate — replacement |
| `(known after apply)` | a value nobody can know yet |

That last line deserves a pause. The `pages`
resource's `content` is "(known after apply)"
because the text embeds the random server name,
and the name doesn't exist until the random
provider generates it during apply. Honest
unknowability is printed as such, never guessed.

Plans end with a summary and an outputs forecast —
memorise the shape of this line, you will read it
a thousand times:

```
Plan: 10 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + admin_token=<redacted>
  + banner_sha256   = "7a509ab4f7bc8f42619a533e43bdfa0a94c7d904b06aa50d45e9e900e69973a1"
  + generated_files = [
      + "./out/dev-about.txt",
      + "./out/dev-index.txt",
    ]
  + note_file       = "./out/note.txt"
  + server_name     = (known after apply)
  + settings        = (known after apply)
```

Two details: the sensitive output shows as
`<redacted>` (the State chapter explains why that
is display-deep only), and the checksum of the
banner file is already known — the data source was
read during planning, so anything derived purely
from reads can be shown exactly.

## apply: agree, then watch it happen

`terraform apply` computes the same plan, shows
it, and asks `yes` before proceeding
(`-auto-approve` skips the question; the lab used
it, your production account should not). It then
executes in dependency order, printing each step:

```
random_pet.server: Creation complete after 0s [id=correct-dane]
null_resource.build_log (local-exec): Executing: ["/bin/sh" "-c" "echo applied dev on correct-dane >> ./out/build.log"]

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

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

The summary's three numbers always mirror the
plan's. If apply fails halfway, Terraform stops,
saves the state of what *did* happen, and the next
plan picks up from there — partial progress is
normal and recoverable, not corruption.

**Check:** the files exist and contain what the
configuration promised:

```
$ ls out/
build.log  dev-about.txt  dev-index.txt  note.txt  stamp-0.txt  stamp-1.txt

$ cat out/dev-index.txt
FIELD NOTES - generated locally, managed by Terraform.
Page: index
Server: correct-dane
Message: Deployed by hand the first time.
```

## Two more plan shapes worth meeting early

**Nothing to do.** Plan immediately after a
successful apply, with nothing changed:

```
$ terraform plan
...
No changes. Your infrastructure matches the configuration.
```

That sentence is the sound of desired state
achieved, and it is what makes re-running apply
safe to automate.

**A saved plan.** `terraform plan -out=demo.tfplan`
writes the exact plan to a file;
`terraform show demo.tfplan` reads it back, and
`terraform apply demo.tfplan` executes *that*
plan — no re-planning, no prompt. Both were run in
the lab exactly so. This is how teams separate
"approve the change" from "run the change": a
pipeline produces the plan file, a human reads it,
and apply consumes the very same file.

## destroy

`terraform destroy` plans the mirror image —
everything in state, deleted — and, after the same
`yes`, does it. The Worked Example ends with one;
the summary line there reads "Destroy complete!
Resources: 10 destroyed." Destroy is a real plan
with real deletions, and it deserves the same
careful read as any apply. What destruction
*doesn't* reach is also instructive, and saved for
that chapter.
