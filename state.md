# State

Terraform's **state** is a record — by default a
file, `terraform.tfstate`, in the project
directory — of everything Terraform is managing:
each resource's address, the real-world ID it was
given, and its last-known attributes, plus the
current values of outputs.

It exists because a plan is a diff, and a diff
needs two sides. The configuration says what
*should* exist; the state says what Terraform
*last saw*. Refresh compares state with reality;
plan compares configuration with the refreshed
picture. Without state, Terraform would have to
rediscover the world from scratch on every run —
and for most APIs there is no reliable way to ask
"which of these thousands of objects are mine?"

Delete the state of a real project and Terraform
doesn't lose the resources — it loses *track* of
them. They keep existing (and billing), now
unmanaged, while the configuration insists on
creating fresh copies. State is small and boring
and absolutely load-bearing.

## Looking at it

Two read-only commands cover daily needs:

```
$ terraform state list
data.local_file.banner
local_file.pages["about"]
local_file.pages["index"]
local_file.stamp[0]
local_file.stamp[1]
null_resource.build_log
random_id.build
random_password.admin_token
random_pet.server
terraform_data.settings
module.note.local_file.note
```

Note the addresses: the data source is listed
(its read result is recorded), the module's
resource carries its full path
(`module.note.local_file.note`), and repeated
resources appear once per instance.

`terraform state show` prints one instance as
Terraform last recorded it — here a generated
page, with the heredoc content resolved and every
checksum the provider computed:

```
$ terraform state show 'local_file.pages["index"]'
# local_file.pages["index"]:
resource "local_file" "pages" {
    content              = <<-EOT
        FIELD NOTES - generated locally, managed by Terraform.
        Page: index
        Server: correct-dane
        Message: Deployed by hand the first time.
    EOT
    content_md5          = "535bca886f584e243121e170da5a3374"
    content_sha256       = "2e49eac1b88771c4e5e878a5f7b6fe2806ca5e11a12ff6797d5ba51bbe7a15b2"
    # ...base64 and sha512 checksum attributes elided
    directory_permission = "0777"
    file_permission      = "0777"
    filename             = "./out/dev-index.txt"
    id                   = "99512c457ea3607fd471c3fbb23ea812dc67d8f2"
}
```

## The uncomfortable fact: state holds secrets, in plain text

Marking a value `sensitive` (next chapter) hides
it from console output. It does **not** encrypt
it. The state file is JSON, and anything a
provider returns — including generated passwords —
is stored in it verbatim. This was checked
directly on the example project, without printing
the secret: the token is 16 characters long (via
`terraform output -raw admin_token | wc -c`), and
a search of `terraform.tfstate` for that exact
string returns **true**:

```
token length: 16
token appears verbatim in terraform.tfstate: True
```

Meanwhile `terraform state show
random_password.admin_token` politely prints
`result = (sensitive value)`. Display manners,
storage reality. Consequences, not optional:

- Treat `terraform.tfstate` (and its
  `terraform.tfstate.backup` sibling, written
  before each change) as a **secret file**: never
  commit it, never paste it into a ticket.
- Projects conventionally ship a `.gitignore`
  covering `*.tfstate*`, `.terraform/`, and
  `*.tfvars` for the same reason.

## Where state lives: backends **(documented)**

So far the state is a local file — fine for one
person on one machine. The place state is stored
is chosen by a **backend** configuration. Real
teams store state remotely (Amazon S3, Google
Cloud Storage, Azure Storage, or HCP Terraform),
which buys three things local files can't: a
shared copy the whole team plans against,
**locking** so two applies can't interleave, and
a backup that survives a laptop. None of that was
run for this guide — no cloud accounts were
involved — and the Working Safely chapter covers
migrating between backends at the same
documented level. The concepts to carry away:
backend = where state lives; remote = shared,
locked, backed up; local = start here, outgrow it
on purpose.

## Rules that are not negotiable

- **Never edit state by hand.** It is a database
  in JSON clothing. Terraform provides surgical
  commands (`state mv`, `state rm`) for the rare
  legitimate need **(documented)** — renaming a
  resource in configuration without recreating
  it, mainly — and the safe order is: back up,
  use the command, plan to confirm nothing else
  changed.
- **Never let two applies run at once** against
  one state. Remote backends lock; a local file
  does not stop you.
- **Back state up** before anything unusual. The
  automatic `.backup` file covers the last change,
  not history.
