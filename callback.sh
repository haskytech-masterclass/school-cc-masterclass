#!/bin/bash
# Delivers the OAuth callback URL to Claude Code
# Strips backslashes that Codespaces terminal auto-adds on paste

echo ""
echo "Paste the URL from your browser (starts with http://localhost...),"
echo "then press Enter, then Ctrl+D:"
echo ""

cat > /tmp/claude_callback_url.txt

# Strip backslashes and whitespace
URL=$(sed 's/\\//g' /tmp/claude_callback_url.txt | tr -d '\n' | tr -d ' ')

echo ""
echo "Sending callback..."
RESULT=$(curl -s "$URL" 2>&1)

sleep 2

STATUS=$(claude auth status 2>&1)
if echo "$STATUS" | grep -q '"loggedIn": true'; then
    echo ""
    echo "✅ Login successful! Go back to your other terminal and Claude Code should be ready."
    echo "   If not, close it (Ctrl+C) and run: claude"
else
    echo ""
    echo "❌ Didn't work. Make sure Claude Code is still running in the other terminal,"
    echo "   then try again: bash callback.sh"
fi

rm -f /tmp/claude_callback_url.txt
