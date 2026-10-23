# Fedora Setup

A repository for Fedora workstation setup notes or scripts. The exact scripts and supported Fedora releases should be verified from the repository files before running them.

## Before using this repository

- Review each script before executing it.
- Confirm the target Fedora version and whether root privileges are required.
- Back up important configuration files before applying system changes.
- Understand each package, repository, service, or kernel setting that a script modifies.

## Recommended workflow

1. Inspect the repository files and identify the main setup script.
2. Read the script and its comments.
3. Run non-destructive checks first.
4. Apply changes in small steps and record any manual configuration.
5. Reboot only when required and verify the resulting system state.

## Documentation checklist

For each setup script, document its purpose, supported versions, dependencies, commands, expected output, rollback procedure, and known risks.

## Security

Do not commit private SSH keys, access tokens, machine-specific secrets, or unredacted system logs. Avoid running remote scripts with elevated privileges unless their source has been reviewed.

## Status

This README is a starting point pending verification of the repository's actual scripts and supported Fedora versions.
