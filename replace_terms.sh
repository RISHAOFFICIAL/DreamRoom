#!/bin/bash
FILES=(
    "web/src/components/JoinRoom.tsx"
    "web/src/components/PartyRoom.tsx"
    "web/src/components/RevealSequence.tsx"
    "web/src/components/AdminDashboard.tsx"
    "web/src/components/DreamArchive.tsx"
    "web/src/components/DreamShop.tsx"
    "web/src/App.tsx"
    "backend/src/types.ts"
    "backend/src/socket.ts"
    "backend/src/db.ts"
    "backend/src/server.ts"
)

# Go to the script's directory (shared DreamRoom root)
cd "$(dirname "$0")"

for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "Processing $FILE"
        sed -i "s/Ritual Leader/Gathering Leader/g" "$FILE"
        sed -i "s/ritual leader/gathering leader/g" "$FILE"
        sed -i "s/Enter the Ritual/Enter the DreamRoom/g" "$FILE"
        sed -i "s/Ritual Reveal/The Big Reveal/g" "$FILE"
        sed -i "s/ritual reveal/the big reveal/g" "$FILE"
        sed -i "s/Ritual Kits/Dream Kits/g" "$FILE"
        sed -i "s/ritual kits/dream kits/g" "$FILE"
        
        # Specific code replacements
        sed -i "s/ritualRevealTriggered/goldenRevealTriggered/g" "$FILE"
        sed -i "s/ritual_reveal_triggered/golden_reveal_triggered/g" "$FILE"
        
        # General Ritual replacements (careful with these)
        sed -i "s/THE GOLDEN RITUAL/THE GOLDEN GATHERING/g" "$FILE"
        sed -i "s/The Ritual/The Gathering/g" "$FILE"
        sed -i "s/the ritual/the gathering/g" "$FILE"
        sed -i "s/active rituals/active gatherings/g" "$FILE"
        sed -i "s/ritual monitoring/gathering monitoring/g" "$FILE"
        sed -i "s/Continue the Ritual/Continue the Gathering/g" "$FILE"
        sed -i "s/Add Energy to the Ritual/Add Energy to the DreamRoom/g" "$FILE"
        sed -i "s/Back to Ritual/Back to Gathering/g" "$FILE"
    else
        echo "File not found: $FILE"
    fi
done
