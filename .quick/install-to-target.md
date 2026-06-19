# Install .ai.ui Into a Target Project

## Copy mode — clean file copy (recommended for most cases)

```text
@ui-install copy - /absolute/path/to/my-project
# Creates /absolute/path/to/my-project/.ai.ui/ (only git-tracked files)
# Excludes: .git/, .github/, .gitignore, .cursorrules, node_modules/,
#           dist/, credentials/, tmp/, examples/*.png — everything in .gitignore
```

If the path already includes `.ai.ui`:

```text
@ui-install copy - /absolute/path/to/my-project/.ai.ui
```

## Submodule mode — git submodule (track version via submodule)

```text
@ui-install submodule - /absolute/path/to/my-project
# Requires origin remote on .ai.ui source repo
# Creates /absolute/path/to/my-project/.ai.ui/ as a git submodule
# After: commit .gitmodules in target project
```

## Check install status

```text
@ui-install status
```

## Next steps in the target project

```text
@ui-bootstrap init merge-cursorrules
@ui-project-approach - <describe project>
```

## Examples

```text
@ui-install copy - /home/user/work/ecommerce-platform
@ui-install copy - /home/user/work/ecommerce-platform/.ai.ui
@ui-install submodule - /home/user/work/internal-admin
```
