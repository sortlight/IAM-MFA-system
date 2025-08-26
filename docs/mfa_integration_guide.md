# MFA Integration and Attack Mitigation Guide

## Core Flows
(See README for overview.)

## Bash Scripts Explained

- **setup.sh**: Uses if-checks for prereqs, pip/docker commands for install/start, sed for .env editing. Idempotent via file checks.

- **attack_simulator.sh**: Reads creds file, loops with curl POSTs, greps for tokens, logs with tee. Random sleep avoids flooding.

- **monitor.sh**: Infinite loop tails logs, curls for health, alerts on failure. Simple but extensible (add email with mailx).

## Attack Demo
Run scripts with MFA on/off—Bash version is curl-native, faster for ops demos.
