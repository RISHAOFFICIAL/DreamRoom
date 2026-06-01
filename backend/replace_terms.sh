#!/bin/bash
FILES=(
    "dreamroom-web/src/components/JoinRoom.tsx"
    "dreamroom-web/src/components/PartyRoom.tsx"
    "dreamroom-web/src/components/RevealSequence.tsx"
    "dreamroom-web/src/components/AdminDashboard.tsx"
    "dreamroom-web/src/App.tsx"
    "dreamroom-backend/src/types.ts"
    "dreamroom-backend/src/socket.ts"
    "../team/shared/backend_specs.md"
    "../team/shared/deployment_info.md"
)

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
    fi
done
