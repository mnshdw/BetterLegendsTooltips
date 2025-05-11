::ModBetterLegendsTooltips.TooltipHelper <- {
	function processTooltip(tooltip) {

		if (::ModBetterLegendsTooltips.Enabled == false) {
			return tooltip;
		}

		// Special case: if tooltip has only one entry with text "Unknown garrison", return it untouched
		if (tooltip.len() == 1 && "type" in tooltip[0] && tooltip[0].type == "text" && "text" in tooltip[0] && tooltip[0].text == "Unknown garrison") {
			return tooltip;
		}

		// Iterate through the tooltip entries and group them by icon and text
		local groupedEntities = {};
		foreach(index, entry in tooltip) {
			if ("type" in entry && entry.type == "text" && "text" in entry && "icon" in entry) {
				local baseName = entry.text;
				local isChampion = true;

				// Check if the entity name starts with a number or pronoun (A/An)
				if (baseName.len() > 0) {
					local numberEndPos = 0;
					local hasLeadingNumber = false;

					// Find where the number ends (if any)
					for (local i = 0; i < baseName.len(); i++) {
						local c = baseName.slice(i, i + 1);
						if (c == "0" || c == "1" || c == "2" || c == "3" || c == "4" ||
							c == "5" || c == "6" || c == "7" || c == "8" || c == "9") {
							numberEndPos = i + 1;
							hasLeadingNumber = true;
						} else {
							break;
						}
					}

					// Check if the number is followed by a space
					if (hasLeadingNumber && numberEndPos < baseName.len() && baseName.slice(numberEndPos, numberEndPos + 1) == " ") {
						isChampion = false;
					} else if (baseName.len() >= 2 && baseName.slice(0, 2) == "A ") {
						isChampion = false;
					} else if (baseName.len() >= 3 && baseName.slice(0, 3) == "An ") {
						isChampion = false;
					}
				}

				// If MergeNamedEnemies is enabled, try to determine the base name of the entity
				if (::ModBetterLegendsTooltips.MergeNamedEnemies && "icon" in entry && typeof entry.icon == "string" && isChampion) {
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
				local key = entry.icon + "|" + baseName + "|" + (isChampion ? "champion" : "normal");
				if (key in groupedEntities) {
					groupedEntities[key].count++;
				} else {
					groupedEntities[key] <- {
						count = 1,
						entry = entry,
						isChampion = isChampion
					};
				}
			}
		}

		// Clear the tooltip and rebuild it with grouped entries
		local newTooltip = [];
		foreach(key, group in groupedEntities) {
			local entry = group.entry;
			if (group.count > 1) {
				entry.text = group.count + (group.isChampion ? " [color=800808]Champion[/color] " : " ") + entry.text;
			} else if (group.isChampion) {
                entry.text = "[color=800808]Champion[/color] " + entry.text;
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