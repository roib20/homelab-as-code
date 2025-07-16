# Task UI History

This directory contains terminal recordings (`.ttyrec` files) of task executions from the Task UI web interface.

## What is ttyrec?

ttyrec is a terminal recording utility that captures all terminal input and output to a file. When you run tasks through the Task UI web interface with history enabled, each task execution is recorded using `ttyrec` (from the [ovh-ttyrec](https://github.com/ovh/ovh-ttyrec) project).

## How it works with Task UI

1. **Recording**: When you execute a task through the Task UI web interface, the execution is wrapped with `ttyrec` which captures:
   - All terminal output (stdout/stderr)
   - Command execution timing
   - Exit codes and status

2. **File naming**: Recordings are saved as `{task-name}-{timestamp}.ttyrec`
   - Example: `info_tools-1752223630.ttyrec` for the `info:tools` task

3. **Storage**: Recordings are stored in this directory and mounted as a volume in the Task UI container

## Playback

You can replay these terminal sessions using:

```bash
# Using ttyplay from the container
docker exec homelab-as-code-task-ui ttyplay /home/runner/task-ui-history/filename.ttyrec

# Or run an interactive shell in the container and use ttyplay directly
docker exec -it homelab-as-code-task-ui bash
ttyplay /home/runner/task-ui-history/filename.ttyrec
```

## Available tools

The container includes these ttyrec utilities:

- `ttyrec` - Records terminal sessions

- `ttyplay` - Plays back ttyrec files

- `ttytime` - Analyzes timing information in ttyrec files

## Benefits

- **Debugging**: Review exactly what happened during a task execution
- **Audit trail**: Keep a record of all task executions with timestamps
- **Collaboration**: Share task execution recordings with team members
- **Learning**: Understand what commands and outputs were produced

## File Format

The `.ttyrec` files are in the standard ttyrec format, which includes:

- Timestamp data for each frame

- Raw terminal output

- Timing information for accurate playback

These files can be played back with any ttyrec-compatible player.
