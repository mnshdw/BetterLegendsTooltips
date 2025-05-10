::ModBetterLocationTooltips.TooltipHelper <- {
    function processTooltip(tooltip) {

        // Iterate through the tooltip entries and group them by icon and text
        local groupedEntities = {};
        foreach(index, entry in tooltip) {
            if ("type" in entry && entry.type == "text" && "text" in entry && "icon" in entry) {
                local baseName = entry.text;

                // If MergeNamedEnemies is enabled, determine the base name of the entity
                if (::ModBetterLocationTooltips.MergeNamedEnemies && "icon" in entry && typeof entry.icon == "string") {
                    // Extract the entity ID from the icon
                    local lastSlash = entry.icon.find("/");
                    while (lastSlash != null) {
                        local nextSlash = entry.icon.find("/", lastSlash + 1);
                        if (nextSlash == null) break;
                        lastSlash = nextSlash;
                    }
                    local lastDot = entry.icon.find(".", lastSlash);
                    local iconName = entry.icon.slice(lastSlash + 1, lastDot);

                    local entityIndex = ::Const.EntityIcon.find(iconName);
                    if (entityIndex != null && entityIndex in ::Const.Strings.EntityName) {
                        baseName = ::Const.Strings.EntityName[entityIndex];
                        entry.text = baseName;
                    }
                }

                // Group by icon and base name
                local key = entry.icon + "|" + baseName;
                if (key in groupedEntities) {
                    groupedEntities[key].count++;
                } else {
                    groupedEntities[key] <- {
                        count = 1,
                        entry = entry
                    };
                }
            }
        }

        // Clear the tooltip and rebuild it with grouped entries
        local newTooltip = [];
        foreach(key, group in groupedEntities) {
            local entry = group.entry;
            if (group.count > 1) {
                entry.text = group.count + " [color=800808]Champion[/color] " + entry.text;
            }
            newTooltip.push(entry);
        }

        // Sort the entries by icon and ensure non-champions come before champions
        newTooltip.sort(function(a, b) {
            if ("icon" in a && "icon" in b) {
                if (a.icon == b.icon) {
                    local aIsChampion = a.text.find("Champion[/color]") != null;
                    local bIsChampion = b.text.find("Champion[/color]") != null;
                    return aIsChampion && !bIsChampion ? 1 : (!aIsChampion && bIsChampion ? -1 : 0);
                }
                return a.icon < b.icon ? -1 : (a.icon > b.icon ? 1 : 0);
            }
            return 0;
        });

        // Add non-text entries back to the tooltip
        foreach(index, entry in tooltip) {
            if (!("type" in entry && entry.type == "text" && "text" in entry && "icon" in entry)) {
                newTooltip.push(entry);
            }
        }

        return newTooltip;
    }
}