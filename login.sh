#!/bin/bash
# Claude Code login helper for GitHub Codespaces
# Handles the OAuth callback that can't reach localhost in a codespace

echo ""
echo "=== Claude Code Login ==="
echo ""
echo "  Step 1: Run 'claude' in the terminal"
echo "  Step 2: Select option 2 — 'Anthropic Console account'"
echo "  Step 3: A browser tab will open — sign in there"
echo "  Step 4: After signing in, the browser will show an error page"
echo "  Step 5: Copy the URL from your browser address bar"
echo "  Step 6: Come back here and run: bash callback.sh"
echo "  Step 7: Paste the URL, press Enter, then Ctrl+D"
echo ""
echo "Starting Claude Code now..."
echo ""

claude
