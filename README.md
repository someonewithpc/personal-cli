# personal

The command-line client for my to-do and PR list. The site itself lives in a private repo.
This is one Python file with no dependencies, so agents and I can read and change the list
from any shell.

## Setup

The token goes in `~/.config/personal/token` (or `$PERSONAL_TOKEN`). The rest goes in
`~/.config/personal/config.json`:

```json
{
  "url": "https://example.com",
  "emails": ["me@example.com"],
  "freedesktop_username": "me"
}
```

`emails` and `freedesktop_username` only matter to `personal watch`, so it can skip my own
replies. `$PERSONAL_URL`, `$MY_EMAILS` (comma-separated) and `$FREEDESKTOP_USERNAME`
override the file.

With Nix, the flake's `packages.default` is the CLI, and `homeManagerModules.default` installs
it and writes the config file:

```nix
programs.personal = {
  enable = true;
  url = "https://example.com";
  emails = [ "me@example.com" ];
  freedesktopUsername = "me";
};
```

The token stays out of the Nix store, so put it in place yourself.

## Use

```sh
personal ls --mine                       # what needs me
personal ls --kind pr --area Fingerprint
personal show voxtype#903                # by id, ref or URL
personal add "Measure VRR on vs off" --area "VRR and PSR" --host helium
personal add "drm: fix" --pr --notes "Branch foo, waiting on Sashiko"
personal set 43 --state unsent           # reviewed, ready to send
personal add "Fix the thing" --url https://github.com/o/r/pull/1 --move them
personal set 42 --notes "..." --log "Rebased onto 7.3"
personal set 42 --theme Kernel/amdgpu/eDP # where it sits on the PR map
personal set 42 --map hidden             # keep it off the PR map
personal set 42 --prs "51 hy3#344"       # a to-do for those PRs, which keeps it off the map
personal set 42 --kind pr                # a to-do that became a patch
personal done 42                         # to-do done, or PR merged
personal done 42 --state closed          # to-do not needed, or PR closed unmerged
personal seen 42
personal check                           # make the site poll now
personal watch                           # poll freedesktop GitLab and sourceware from here
```

A theme is a path of any depth, split on `/`. The site's PR map groups PRs by it, then by
repository. Open to-dos show on it too, under their theme or else their area, unless they're part of a PR. `add` and `set` say when a theme starts a new group
and suggest existing groups it may have meant: `OCTT` finds `CAD/OCCT`, `PSR` finds
`Kernel/amdgpu/VRR and PSR`, and a title naming a group, like Sashiko, finds `Tools/Sashiko`.

After `add`, it lists up to five items that may be the same work: ones sharing a commit hash,
branch, worktree, URL or C/C++ name with the new item, or most of its title words. It also
says which areas and themes those items use, when the new one differs. Read them, then merge
a duplicate or move the new item.

`--json` prints what the API returned. Every change is logged with who made it: the
hostname, or `<host>/claude` inside Claude Code, or `$PERSONAL_AGENT`.

`personal watch` exists because gitlab.freedesktop.org challenges every request from a
Cloudflare Worker, so the site can't poll it. Reading MR comments there needs a token with
Merge Request read access in `$FREEDESKTOP_TOKEN`.
