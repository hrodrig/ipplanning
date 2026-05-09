# Contributing to IPPLANNING

Thanks for helping improve IPPLANNING.

## Ground rules

- Follow the [Code of Conduct](CODE_OF_CONDUCT.md).
- For **security issues**, do not open a public issue with exploit details. Use [GitHub Security advisories](https://github.com/hrodrig/ipplanning/security/advisories/new) for the repository, or contact the maintainers privately.

## How to contribute

- **Bugs and ideas:** Open an [issue](https://github.com/hrodrig/ipplanning/issues). Describe what you expected, what happened, and how to reproduce (commands, `database.yml` redacted snippets, Rails/MySQL versions if relevant).
- **Code:** Open a pull request **against `develop`**. `main` is for production-ready releases; feature work merges into `develop` first.

Use focused branches, for example `fix/short-topic` or `feat/short-topic`.

## Before you open a PR

1. **Tests:** `bin/rails test` must pass. Add or update tests when behavior changes.
2. **Lint:** When RuboCop (or another linter) is added to the project, run the documented command and fix offenses before merging.
3. **Gitignore:** This repo uses a **whitelist** `.gitignore` (ignore-by-default; only `!` exceptions are tracked). If you add a new top-level file or directory that must be in git, add a matching `!path` line in `.gitignore` (see the comment block at the top of that file).

Keep commits scoped and messages clear.

## Project language

Repository content (code, comments, docs, UI strings) should be **English**, per project conventions.

## Questions

If something is unclear, open an issue so scope and design can be discussed there.

## Resources

New to open source? The [Open Source Guide](https://opensource.guide/how-to-contribute/) covers general contribution practices.
