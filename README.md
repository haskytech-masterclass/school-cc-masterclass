# Claude Code Masterclass

Build software with AI using Claude Code — an AI coding assistant that runs in your terminal.

## Before the Masterclass

Please complete these steps **before** the session:

### 1. Create a GitHub account (if you don't have one)
- Go to [github.com](https://github.com) and sign up (free)

### 2. Join our GitHub organization
- Click the invite link shared by your instructor
- Accept the invitation

### 3. Create an Anthropic Console account
- Go to [console.anthropic.com](https://console.anthropic.com) and sign up (free, no credit card needed)
- Click the invite link shared by your instructor to join the masterclass organization
- This is what powers Claude Code — your instructor covers the cost

## Getting Started (During the Masterclass)

### 1. Create your own repo from this template

Click the green **"Use this template"** button at the top of this page, then:
- **Owner**: select `haskytech-masterclass`
- **Repository name**: `yourname-masterclass` (e.g., `alice-masterclass`)
- **Visibility**: Private
- Click **"Create repository"**

### 2. Launch your Codespace

On your new repo page:
- Click the green **"Code"** button
- Select the **"Codespaces"** tab
- Click **"Create codespace on main"**
- Wait ~60 seconds for the environment to build

### 3. Log in to Claude Code

Once VS Code loads in your browser:

**Terminal 1:**
```bash
claude
```
- Select **option 2** — "Anthropic Console account"
- A browser tab will open — sign in with your Anthropic Console account
- After signing in, the browser will show an error page — **that's normal**
- **Copy the URL** from your browser address bar (it starts with `http://localhost...`)

**Terminal 2** (open a new terminal tab with `` Ctrl+Shift+` ``):
```bash
bash callback.sh
```
- Paste the URL you copied, press **Enter**, then **Ctrl+D**
- You should see "Login successful!"

### 4. Start Claude Code

Go back to Terminal 1. Claude Code should now be ready. If not, run:

```bash
claude
```

That's it — you're ready to go!

## What You Can Do

Claude Code can help you build anything. Try asking it to:

- "Create a simple todo app with HTML and JavaScript"
- "Build a Python script that fetches weather data"
- "Help me write a REST API with Express"
- "Create a React app with a dashboard"

### Useful Commands

| Command | What it does |
|---------|-------------|
| `claude` | Start Claude Code |
| `claude "do something"` | Start with a specific task |
| `/help` | Show help inside Claude Code |
| `Ctrl+C` | Cancel current operation |
| `Escape` | Exit Claude Code |

## Tips

- **Be specific** — "Build a todo app with add, delete, and mark-complete" works better than "build an app"
- **Iterate** — start simple, then ask Claude to add features one at a time
- **Review the code** — Claude shows you what it's writing. Read along and learn!
- **Ask questions** — "Explain what this code does" or "Why did you use this approach?"

## Need Help?

Raise your hand or ask your instructor.
