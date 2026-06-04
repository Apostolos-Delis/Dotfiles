# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy for dev command output.

## Meta Commands

```bash
rtk gain
rtk gain --history
rtk discover
rtk proxy <cmd>
```

## Verification

```bash
rtk --version
rtk gain
which rtk
```

Warning: if `rtk gain` fails, the installed binary may be the wrong `rtk` project.

## Hook-Based Usage

Claude Code shell commands are rewritten by the `rtk hook claude` Bash hook.

Example:

```bash
git status
```

is transparently executed through RTK as:

```bash
rtk git status
```
