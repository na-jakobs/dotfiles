#!/usr/bin/env bash

# A little frontend for the Jira CLI
#
# Prerequisites:
# https://github.com/ankitpokhrel/jira-cli
# https://github.com/charmbracelet/gum
#
# For Jira server you need to set auth to bearer:
# JIRA_AUTH_TYPE=bearer
# JIRA_API_TOKEN=your_token
#

echo "Type of ticket to create:"

type=$(printf "Story\nBug\nTask" | gum choose --limit 1)

echo "$type"

text=$(gum input --placeholder "JIRA ticket summary and body")

if [[ $text == "" ]]; then
  echo "No input provided, exiting."
  exit 1
fi

user=$(jira me)

printf '# Going to create Jira issue with the following details:\n - Type: %s\n - Summary: %s\n - Assignee: %s' "$type" "$text" "$user" | gum format
echo " "
gum confirm "Create ticket?" || exit 1
echo " "

# Capture the output from the jira issue create command
result=$(jira issue create \
  --type="$type" \
  --summary="$text" \
  --assignee="$user" \
  --project='NFSAAS' \
  --body="$text" \
  --custom technical-owner='Team Diamond' \
  --label='OOBDelivery' \
  --label='github' \
  --no-input)

# Print the result for the user
echo "$result"

# Extract the URL from the output (assuming it is on a line that starts with "https")
url=$(echo "$result" | grep -Eo 'https://[^[:space:]]+')

if [[ -z "$url" ]]; then
  echo "No URL found in the output."
  exit 0
fi

echo "Opening JIRA URL: $url"

# For macOS use 'open', for Linux use 'xdg-open'
if command -v open &>/dev/null; then
  open "$url"
elif command -v xdg-open &>/dev/null; then
  xdg-open "$url"
else
  echo "Neither 'open' nor 'xdg-open' command found. Please open the URL manually."
fi
