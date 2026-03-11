#!/bin/bash
# Claude Code login helper for GitHub Codespaces
# Handles the OAuth callback that can't reach localhost in a codespace

echo "=== Claude Code Login Helper ==="
echo ""
echo "This will open a login page in your browser."
echo "After signing in, the page will show an error — that's normal!"
echo ""
echo "Steps:"
echo "  1. Sign in on the page that opens"
echo "  2. When you see a 'can't reach this page' error, copy the URL from your browser"
echo "  3. Come back here and paste it"
echo ""

# Start claude auth login in the background, capture output
claude auth login 2>&1 &
AUTH_PID=$!

# Wait for the auth to complete or for user input
sleep 3

echo ""
echo "Paste the URL from your browser (the one that starts with http://localhost):"
echo "(It's OK if it looks messy with backslashes — we'll clean it up)"
echo ""

# Read the URL
cat > /tmp/claude_callback_url.txt
URL=$(sed 's/\\//g' /tmp/claude_callback_url.txt | tr -d '\n')

echo ""
echo "Sending callback..."
RESULT=$(curl -s "$URL" 2>&1)

# Wait for auth process
sleep 2

# Check if it worked
STATUS=$(claude auth status 2>&1)
if echo "$STATUS" | grep -q '"loggedIn": true'; then
    echo ""
    echo "✅ Login successful! Run 'claude' to start."
else
    echo ""
    echo "❌ Login may have failed. Try running this script again."
    echo "Make sure to paste the URL quickly after signing in."
fi

# Clean up
kill $AUTH_PID 2>/dev/null
rm -f /tmp/claude_callback_url.txt
