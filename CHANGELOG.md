# Changelog

All notable changes are documented here. Format based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.3] - 2026-11-28

### Added (macOS)
- **Notarised by Apple:** the app and disk image are signed with a Developer ID, so a first install opens without the *Open Anyway* step.
- **Language logos:** files show the logo of their language or tool (about 100, from Simple Icons) in its brand colour, with lettered tiles where no logo exists. Many more extensions and file names are recognised.
- **Filter the Changes list:** a search box appears once more than 20 files have changed. Stage All and Unstage All become *Stage Shown* and *Unstage Shown* while a filter is active.

### Added (Windows)
- **Repository icons:** right-click a tile and choose *Change icon…* for a symbol, a tile colour or a picture, or drop a picture on the tile. Pictures are stored in the app's data folder, never in the repository. (Thanks to Rage-Gaming.)
- The app and taskbar now use the wolf icon.

### Changed
- The website has a working demo window of the app on Mac and Windows, and no navigation bar.

## [0.2.0] - 2026-11-28

### Added (macOS)
- **First-run welcome:** checks Git, connects an account, finds repositories in a folder you pick, and sets appearance and accent. Shown once, every step skippable, never shown to existing users.
- **Repository statistics** (Repository > Statistics…): commits per week, contributors, hot and high-churn files, and who works in each folder.
- **Pull Requests Across Repositories** (Hosting menu, ⌥⌘P): open pull requests from every open repository, split into Mine, Others and CI failing.
- **Command line and links:** `gitwolf [folder]` (install it in Settings), `gitwolf://open?path=` links, and folders dropped on the Dock icon open as repositories.
- **Notifications** when CI for the checked-out commit finishes while GitWolf is in the background (Settings to turn off).
- **Undo** now switches back after a checkout and rewinds a whole rebase; a **Breaking Change** toggle in the commit helpers; **Copy Release Notes Since This Tag** on any tag.
- **New wolf logo** (app icon, About window, Home screen, menu bar) and a **GitWolf blue** default accent. New About window and Help > Contributors.
- **Install:** Homebrew (`brew install --cask ipuppyyt/gitwolf/gitwolf`, skips the Open Anyway step), a project website, and install steps in the README.
- Provider errors now show the server's reason, with *Sign In Again* for browser sign-ins. Copy buttons confirm with "Copied".

### Added (Windows)
- Provider accounts, pull requests and issues, notifications, safer sync and diff tools, matching the Mac app.
- In-app updates (signed feed, verified before install), Open in editor/terminal, and custom actions.
- CI: re-run, cancel and follow checks; a banner to open a pull request after a push.
- Cached profile pictures, success notices, adjustable panel heights, a Copied confirmation, and tests and a build in CI.

### Changed
- Menu bar: the new **Hosting** menu holds New Pull Request, New Issue, Notifications and Fork; the Repository menu is shorter.
- CI lookups pause for five minutes after a host refuses them (rate limit), instead of retrying every few seconds.
- Windows: trust is asked before hooks run, tokens are hidden in URLs, GitHub Actions are pinned, and the app is faster on large repositories.

### Fixed
- The checks "re-run" button gave a vague error when no account was signed in.
- The repository rail clipped tile badges.
- Home screen buttons now share one size.
- Changing the accent in the welcome sheet no longer restarts it.

## [0.1.2] - 2026-11-27

### Changed
- **GitSync is now GitWolf** on macOS and Windows: the app name, bundle identifier (`org.gitwolf.GitWolf`), modules, projects, environment variables (`GITWOLF_*`) and documentation. On first launch, settings, open repositories, repository icons and saved account tokens from the old name are carried over (macOS: preferences, the Application Support folder and the Keychain; Windows: the `%LOCALAPPDATA%` folder).
- Smoother diff scrolling: diff rows only track hover when a line can be staged, instead of one tracking area per row.
- Smoother scrolling: panels draw their shadow on a background shape instead of the scrolling content, and history rows share one relative-date formatter.
- More smoothing: syntax highlighting fades in instead of popping, the file-history diff keeps the old one until the next arrives, and pull request / issue lists and comments fade in.
- Smoother transitions: turning on a history filter (dates, file, author…) keeps the current list, dims it while git searches and then fades the results in instead of flashing an empty state; stash and compare selections fade in the same way.
- Every pane in the repository window is now resizable and remembers its size: the sidebar and list column (wider ranges), the file list above the diff in a commit, and the commit message box in Changes (drag the divider; the pointer changes to a resize cursor).
- Notifications sheet redesigned: a header with icon and subtitle, a compact empty state, a labelled reload button and a footer bar with Mark All as Read and Close.
- Menu bar: removed Services, Hide, Hide Others and Show All from the app menu, and the Edit, View, Format and Window menus (⌘C/V/X/A/Z are still handled for text fields) and merged the Repositories menu into Repository as *Switch Repository*, which lists open repositories by name with ⌘1…9.
- Redesigned the repository rail: narrower, uniform 40 pt tiles, flat tinted tiles that turn solid when selected with an edge marker, a smaller corner badge, no hover scaling or shadows.
- Removed the empty View and Format menus and Edit's AutoFill, Dictation and Emoji items, and grouped the Repository menu with dividers.
- Removed menu items that don't apply: File > New Window, the View menu's toolbar and sidebar toggles, the Format menu, and the empty Help book (replaced by links to the documentation and issue tracker).

### Added
- In-app updates with Sparkle, free of any Apple Developer account: updates are signed with an EdDSA key, the app is signed with a stable self-signed certificate (so Keychain access and permissions survive updates), archives ship on GitHub Releases and the feed on GitHub Pages. First install needs macOS's *Open Anyway* once; updates never do. See `docs/RELEASING.md`. Replaces the old check-and-open-the-release-page flow.
- Sync buttons animate while they run: Fetch spins, Pull and Push slide their arrow in the direction of travel.
- CI checks update on their own: a commit with a running check is polled every 15 seconds, and a just-pushed commit (from the app or a terminal) or one made in the last 30 minutes is looked up every 15 seconds until its run appears. The running state shows an indeterminate ring spinner (the arc stretches and shrinks as it turns) instead of a clock.
- Tile colours: pick a colour for a repository's tile in the icon picker (nine flat colours, or Automatic). The image browser remembers the last folder.
- Merge or rebase by dragging: drag a local branch in the sidebar onto the current branch and choose Merge or Rebase.
- Open a pull request after pushing: when you push a feature branch that has no pull request (first push, or the loaded list shows none), a banner offers *Open Pull Request* with the form prefilled from the branch's commits. It goes away after 30 seconds or when you switch branch.
- CI actions: expand the checks pill to re-run a finished check or cancel a running one (GitHub Actions and GitLab).
- CI on the rail: each repository tile shows the result of its latest commit's checks (spinner, tick or cross) and updates by itself.
- Repository icons: right-click a tile in the rail and choose *Change Icon…* to pick a symbol from a curated set or *Choose Image…* to use your own picture from a built-in file browser (the system open panel hangs inside the app on some Macs) (cropped to a square and stored as a 128 px PNG in Application Support, never in the repository). *Remove Icon* goes back to initials. You can also drop an image file onto a tile, or drop or paste one in the picker, without using the file dialog.
- Menu bar icon: shows the branch symbol and the total changed-file count, and lists open repositories (branch and changes; click to jump to one), recents, Open Repository and Quit. Turn it off in Settings > General > Menu bar icon.
- Update check: *GitWolf > Check for Updates…* and a once-a-day background check (Settings > General > Check for updates) compare the app version with GitHub's latest release and offer to open its page, or skip that version. Nothing is downloaded or installed automatically.
- Release tooling: an app icon (flat, generated by `Scripts/make-icon.swift`), `Scripts/release.sh` (hardened-runtime signing with a Developer ID, notarisation with `notarytool`, stapling, signed disk image and checksum), a tag-triggered release workflow, and `docs/RELEASING.md`. The workflow and notarisation have not been run yet because they need Apple Developer credentials.
- Accessibility: tap-to-select rows (changed files, commits, sidebar branches and tags, commit files) are exposed to VoiceOver and Full Keyboard Access as buttons with spoken labels ("Modified Sources/App.swift"), file rows offer Stage/Unstage as VoiceOver actions, the repository rail, sync buttons and icon-only buttons have labels and values, and Up/Down arrows move through the changed-files list as they already did in history.
- Localisation groundwork: `apple/Scripts/extract-strings.py` collects every SwiftUI string literal into `Resources/en.lproj/Localizable.strings` (`--check` for CI); translators copy it to `<lang>.lproj`, and `bundle.sh` packages all `.lproj` folders.
- Diff improvements: changed words are highlighted inside modified lines (paired deleted/added lines), an *Ignore whitespace* toggle (`git diff -w`; staging is switched off while it is on because the hunks no longer match the file), a *Show whole file* toggle, long runs of unchanged lines fold into a clickable "N unchanged lines" row, and image files (PNG, JPEG, GIF, WebP, BMP, TIFF, HEIC, ICO) show a before/after preview with size and dimensions.
- Open in Finder, Terminal and editor: a toolbar menu, Repository menu items (⌥⌘T terminal, ⌥⌘E editor, ⇧⌥⌘R Finder) and ⌘K entries open the repository root. The editor application is set in Settings > Tools.
- Custom actions: define named shell commands in Settings > Tools. They run with `/bin/sh -c` in the repository root with `GITWOLF_REPO` and `GITWOLF_BRANCH` in the environment (never substituted into the command), and are listed in the toolbar menu, the Repository menu and the palette. A failing action shows its exit code and output.
- Home screen pinning and groups: right-click a repository on the home screen to pin it or add it to a named group. Pinned repositories and groups get their own sections above Recent; groups can be created, renamed and deleted, and repositories removed from home. Layout is saved and paths that no longer exist are dropped.
- Dock integration: the Dock icon shows a badge with the number of files with uncommitted changes across all open repositories (capped at 99+), right-clicking it lists recent repositories, and File > Open Recent lists them in the menu bar with Clear Menu.
- Profile pictures: commit authors in history, commit details and file history, and comment authors on pull requests and issues, show their picture from the hosting platform (GitHub, GitLab, Gitea, Bitbucket Cloud), over their initials until it loads. Only the repository's own platform is asked; no Gravatar or other third party. Pictures are cached for a week.
- Tag icons: sidebar tags get an icon from their name: a star for major releases (`v2.0.0`), a tag for other versions (outlined when the tag is lightweight), a flag for release candidates, a test tube for alpha/beta/preview, a moon for nightly, a seal for `latest`/`stable`, a shield for LTS, a paper plane for deploy markers and a box for backups. The tag chips in the history list use the same icons.
- Branch icons: sidebar branches (local and remote) get an icon chosen from the name: a star for `main`/`master`, a hammer for `develop`, sparkles for `feature/…`, a bug for `fix/…`, a flame for `hotfix/…`, a box for `release/…`, plus `docs`, `test`, `refactor`, `perf`, `chore`, `wip`, `dependabot`, `pr/…` and issue-number branches. The current branch keeps a small green check. The branch chips in the history list use the same icons and colours (remote branches by the name after the remote), and so does the toolbar branch picker.
- Folder icons: the folder that holds a changed file gets a coloured folder icon by name (`src`, `docs`, `tests`, `assets`, `components`, `scripts`, `config`, `.github`, `node_modules`, `dist`, and more), in the changed-files lists, the diff header and the worktrees list. Files inside `node_modules`, `.github`, `dist` and similar keep that folder's look.
- File type icons: every file shows a flat, coloured icon for its type, like the VS Code Material icons: the React atom for `.tsx` and `.jsx`, brand tiles for TypeScript, JavaScript, Python, Go, Rust, Java, Kotlin, Vue, Svelte, HTML, CSS, JSON, Markdown, npm and more, and symbols for Swift, Docker, Git files, images, video, audio, archives, PDFs, lockfiles, scripts and databases. Shown in the changed-files lists, the diff header and file history; hover for the type name.
- Large repositories: when loading history takes over half a second, GitWolf writes git's commit-graph cache once in the background (only a cache under `.git`). On a 100,000-commit repository history loads in about 0.015s instead of 0.4s. History was already paged ("Load More").
- Clone options: an Advanced section in the clone sheet for shallow clones (latest N commits), blobless or treeless filters, a single branch, and submodules. Shallow clones show a banner with "Fetch Full History".
- Git LFS: files stored with LFS (from `.gitattributes`) get an LFS badge in the changed-files list. Works without git-lfs installed.
- Worktrees and submodules: "Worktrees & Submodules…" lists, adds, opens and removes worktrees, and lists submodules with their state, with Initialize, Update All, Update to Latest, Open and Add.
- Patches: export a commit as a `.patch` file, save your uncommitted changes as a patch, and apply patch files to the working tree, to the index, or as commits with author and message kept (`git am`, with a continue/skip/abort banner on conflicts).
- Bisect: right-click commits to mark a bad and a good one, then mark each commit git picks as Good, Bad or Skip from a banner until it names the first bad commit.
- Pull and push options: right-click Pull for merge, rebase or fast-forward only; right-click Push for push with tags, force push with lease (always confirmed) and push to another remote. A rejected push offers to pull first or force push with lease; a diverged fast-forward-only pull says so plainly.
- Remotes: "Manage Remotes…" lists remotes with their URLs (passwords redacted) and adds, renames, changes the URL of or removes them, with fetch and push per remote. URLs with embedded passwords are refused.
- Fork: "Fork Repository…" forks the current repository on GitHub, GitLab, Gitea or Bitbucket Cloud with your connected account, then either makes the fork `origin` and the original `upstream`, or adds it as another remote, and fetches it.
- Notifications: review requests, mentions and assignments from your GitHub, GitLab and Gitea accounts, with a bell and unread count in the toolbar (refreshed every 5 minutes), a list that opens the item on the web and marks it read, and Mark All as Read.
- CI status: a checks summary ("All 38 checks passed", "2 of 9 checks failed") with an expandable list and links to each run, on the selected commit and on pull requests (GitHub check runs and statuses, GitLab pipeline jobs, Gitea and Bitbucket Cloud statuses). Works for public repositories without an account.
- Pull request and issue actions: create a pull/merge request from the current branch (title and base picker, draft, pushes the branch first), create issues, read and add comments, merge (merge commit, squash or rebase, with confirmation), close and reopen, and edit labels. GitHub, GitLab and Gitea; Bitbucket Cloud for pull requests. Needs a connected account; the server's own error text is shown when a request is rejected.
- Commit message helpers: a menu beside the commit box with a conventional-commit type picker (plus scopes taken from the staged folders), an issue reference picker (Closes or Refs, from your open issues), your `commit.template`, reuse of recent messages, and spell checking while typing (on by default, can be turned off).
- Ignore helper: right-click a changed file, then Ignore, to ignore that file, any file with its name, all files with its extension, or its folder; written to `.gitignore` or, with "Only on This Machine", to `.git/info/exclude`. Already-tracked files are untracked (kept on disk) so the rule takes effect.
- Hook output: when a pre-commit, prepare-commit-msg or commit-msg hook rejects a commit, a panel shows everything the hook printed (colour codes stripped), keeps your message, and offers Copy Output and "Commit Without Hooks" (`--no-verify`).
- History search: search all history (not just loaded commits) by message or author, find commits that add or remove a piece of code (pickaxe) or match a regex in their diff, and limit by file or folder and by date range.
- Tag tools: annotated tags (a message makes the tag annotated), push a tag or all tags, delete a tag on the remote, optional push when creating; the sidebar tooltip shows the tag message.
- Branch tools: rename a branch, choose or clear its tracking branch, delete a branch on the remote (with confirmation), and "Clean Up Branches…" listing local branches that are merged or whose remote branch is gone (unmerged ones are flagged).
- Compare any two refs (branches, tags, commits): ahead/behind, the commits, the changed files and a diff for each, optionally only the changes since the common ancestor.
- Blame and file history: per-line authorship (click a line's author to jump to the commit) and a "history of this file" list with the diff of each commit, following renames.
- Pull request and issue descriptions render as Markdown (headings, lists, task lists, quotes, code blocks, rules, inline styling).
- Commit signing: GPG, SSH and X.509 signature badges in commit details (verified, untrusted, unverifiable, bad, expired, revoked), and a Sign checkbox in the commit box that follows `commit.gpgsign` and `user.signingkey`.
- Discard and stash safety: discard confirmations state exactly what is lost (files, lines added/removed, untracked files and size); stash a single hunk; preview a stash (files and diffs) before applying; applying a stash into a file with other local changes falls back to a patch when it can.
- Rebase: interactive rebase editor (reorder by dragging; pick, reword, squash, fixup, drop) from the history menu, "Rebase Current Branch onto This" from branches, and a Pull strategy setting (merge or rebase). Conflicts stop the rebase in the operation banner.
- Reset and undo: Reset Branch to Here (soft, mixed, hard) from the history menu, a Reflog browser (reset, checkout or branch from any earlier HEAD), and Undo Last Change.
- Conflict resolution UI: per-conflict Ours / Theirs / Both choices with side-by-side previews, All Ours / All Theirs, Mark as Resolved (saves and stages); whole-file Keep Ours / Keep Theirs / Delete for delete-modify and binary conflicts.
- In-progress operation banner: detects a merge, rebase, cherry-pick or revert in progress (including a sequence of picks) and offers Continue, Skip and Abort, plus palette commands.
- Hosting provider accounts (GitHub, GitLab, Bitbucket, Gitea/Forgejo/Codeberg, Azure DevOps, including self-hosted) with tokens in the Keychain; authenticated fetch, pull, push and clone for private repositories via `GIT_ASKPASS` (secrets never appear in URLs or config).
- Enterprise and self-managed servers: GitHub Enterprise (Server and ghe.com), GitLab self-managed, Gitea/Forgejo, Bitbucket Data Center; custom ports and http; sign in with a token or a username and password.
- Pull request / merge request and issue lists (GitHub, GitLab, Gitea; Bitbucket Cloud pull requests) with open/closed/all filters, search, paging, details, check out branch and open on web. Public repositories work without an account.
- OAuth browser sign-in: GitHub device flow, GitLab, Gitea and Azure DevOps (Microsoft Entra) authorization code with PKCE (public clients, no secret shipped), Bitbucket Cloud with your own consumer key and secret; tokens refresh automatically.
- Browse and clone repositories from a connected account; "Open on <provider>" links for repository, branch, pull/merge request and commit.
- Hunk and line staging, unstaging and discarding (`PatchBuilder` + `git apply`).
- Multi-repository workspace with a repo rail, persisted across launches.
- ⌘K command palette; frameless window with floating panels and resizable columns.
- `--open=/path` launch flag.
- Initial macOS app (SwiftUI): history with branch graph, working-copy staging and commit,
  branches / remotes / tags / stashes sidebar, fetch / pull / push, live repository watching.
- `GitWolfCore` engine with parsers, graph layout and tests.

### Fixed

- Many Git calls running at once could deadlock and freeze the app or hang the tests.
