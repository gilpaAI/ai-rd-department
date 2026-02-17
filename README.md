# AI R&D Department

An AI-powered project management and development framework built on [Claude Code](https://claude.com/claude-code). It creates a virtual R&D department where AI agents collaborate to turn ideas into shipped software — under human oversight.

## What It Does

You (the CEO/Stakeholder) describe what you want. The AI department handles the rest:

1. **Product Manager** asks clarifying questions and writes requirements
2. **Project Manager** creates plans with timelines and effort estimates
3. **Architect & Tech Lead** design the system and break work into tasks
4. **Developers** write code in parallel using isolated git branches/worktrees
5. **QA Engineer** validates everything before it ships

All communication to you stays in plain language. Technical details stay between the agents.

## Quick Start

### Prerequisites

- [Claude Code CLI](https://claude.com/claude-code) installed and authenticated
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- Git configured with a remote repository

### Setup

```bash
# Clone or create your project repository
git clone <your-repo-url>
cd <your-repo>

# Initialize the PM system
# (Use the /pm:init command inside Claude Code)
```

### Basic Workflow

```
You: "I have an idea for a user dashboard"
 │
 ├─► /idea                        # PM conducts discovery, asks questions
 ├─► /pm:prd-new dashboard        # PM writes Product Requirements Document
 ├─► Gil approves the plan
 ├─► /pm:prd-parse dashboard      # Convert PRD → technical epic
 ├─► /pm:epic-decompose dashboard # Break epic → implementable tasks
 ├─► /pm:epic-start dashboard     # Launch parallel agents to build it
 ├─► /pm:status                   # Check progress anytime
 └─► /pm:epic-close dashboard     # Merge, validate, done
```

## Commands

### Core Workflow

| Command | What It Does |
|---------|-------------|
| `/idea` | Start the discovery process for a new feature |
| `/build` | Begin development on an approved plan |
| `/status` | Get a plain-language progress report |
| `/resume` | Pick up where you left off in a new session |

### Product Requirements

| Command | What It Does |
|---------|-------------|
| `/pm:prd-new <name>` | Create a new PRD |
| `/pm:prd-parse <name>` | Convert PRD into a technical epic |
| `/pm:prd-edit <name>` | Edit an existing PRD |
| `/pm:prd-list` | List all PRDs |
| `/pm:prd-status` | Show PRD statuses |

### Epics (Features)

| Command | What It Does |
|---------|-------------|
| `/pm:epic-decompose <name>` | Break epic into tasks |
| `/pm:epic-start <name>` | Launch agents to build it |
| `/pm:epic-show <name>` | View epic details |
| `/pm:epic-list` | List all epics |
| `/pm:epic-status` | Show epic statuses |
| `/pm:epic-sync <name>` | Sync with GitHub issues |
| `/pm:epic-close <name>` | Complete and merge epic |
| `/pm:epic-merge <name>` | Merge epic branch to main |

### Issues (Tasks)

| Command | What It Does |
|---------|-------------|
| `/pm:issue-start <number>` | Start working on an issue |
| `/pm:issue-show <number>` | View issue details |
| `/pm:issue-status <number>` | Check issue status |
| `/pm:issue-sync <number>` | Sync with GitHub |
| `/pm:issue-close <number>` | Close a completed issue |

### Monitoring

| Command | What It Does |
|---------|-------------|
| `/pm:standup` | Generate a standup report |
| `/pm:next` | Show the next task to work on |
| `/pm:in-progress` | List all in-progress work |
| `/pm:blocked` | List blocked items |
| `/pm:search <query>` | Search across PRDs, epics, and issues |

### Context Management

| Command | What It Does |
|---------|-------------|
| `/context:create` | Initialize project knowledge base |
| `/context:prime` | Load context for a new session |
| `/context:update` | Update context with latest progress |

## Architecture

```
┌─────────────────────────────────────────┐
│  Gil (CEO/Stakeholder)                  │
│  Communicates in plain language only    │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│  Management Layer                       │
│  ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │ Product  │ │ Project  │ │ Budget  │ │
│  │ Manager  │ │ Manager  │ │ Owner   │ │
│  └──────────┘ └──────────┘ └─────────┘ │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│  Technical Layer                        │
│  ┌───────────┐ ┌──────────┐            │
│  │ Architect │ │ Tech Lead│            │
│  └───────────┘ └──────────┘            │
│  ┌─────────┐ ┌─────────┐ ┌──────────┐ │
│  │Frontend │ │Backend  │ │    QA    │ │
│  │  Dev    │ │  Dev    │ │ Engineer │ │
│  └─────────┘ └─────────┘ └──────────┘ │
│  ┌─────────┐ ┌──────────┐             │
│  │ DevOps  │ │UX Design │             │
│  └─────────┘ └──────────┘             │
└─────────────────────────────────────────┘
```

## How It Works

### Parallel Development

Multiple AI agents work simultaneously on different files within the same epic. Each agent:
- Stays in its assigned file scope (no conflicts)
- Commits small, focused changes
- Communicates progress through git commits and status files

### Quality Gates

No code ships without passing through:
1. **Architect approval** on technical design
2. **Tech Lead review** on all code
3. **QA validation** against acceptance criteria

### Git Strategy

- One branch per epic: `epic/<feature-name>`
- Optional worktrees for full isolation: `../epic-<feature-name>`
- Small, atomic commits with issue references
- Merge to main only after all quality gates pass

## Project Structure

```
.claude/
├── agents/          # Specialized AI agent definitions
├── commands/        # All slash commands (pm/, context/, testing/)
├── epics/           # Active epic definitions and tasks
├── prds/            # Product Requirements Documents
├── rules/           # Operating procedures and standards
├── scripts/         # Shell script implementations
├── context/         # Project knowledge base
└── hooks/           # Git and tool hooks
```

## Customization

### Adding Agents

Create a new `.md` file in `.claude/agents/` defining the agent's role, tools, and behavior.

### Adding Commands

Create a new `.md` file in `.claude/commands/` with the command prompt template.

### Modifying Rules

Edit files in `.claude/rules/` to change operating procedures (git workflow, testing standards, etc.).

## License

Private repository. All rights reserved.
