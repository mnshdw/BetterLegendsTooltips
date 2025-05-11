::ModBetterLegendsTooltips.TooltipHelper <- {
	function processTooltip(tooltip) {

		if (::ModBetterLegendsTooltips.Enabled == false) {
			return tooltip;
		}

		// Special case: if tooltip has only one text entry with "Unknown garrison", return it untouched.
		// Usually the layout looks like this:
		// - type=title, text=Artifact Reliquary
		// - type=description, text=A collapsed ruin from days long past etc
		// - type=text, text=Unknown garrison
		// - type=hint, text=This location is on plains
		foreach(index, entry in tooltip) {
			if ("type" in entry && entry.type == "text" && "text" in entry && entry.text == "Unknown garrison") {
				return tooltip;
			}
		}

		// Usually ennemy troops have a "quantifier" prefix that indicates how many of them are there.
		// Depending on Legends setting "Exact engagement numbers", this prefix can be a number or a word,
		// for example:
		// - "A Desert Stalker"
		// - "Some Orc Warriors"
		// - "6 Barbarian Chosen"
		// We detect champions by checking that the name of the entity does *not* start with such quantifiers.

		// First create a list of all quantifier prefixes
		local quantifiers = ["A ", "An "];
		foreach(key, value in ::Const.Strings.EngageEnemyNumbersNames) {
			quantifiers.push(value + " ");
		}

		// Iterate through the tooltip entries and group them by icon and text
		local groupedEntities = {};
		foreach(index, entry in tooltip) {
			if ("type" in entry && entry.type == "text" && "text" in entry && "icon" in entry) {
				local baseName = entry.text;
				local isChampion = false;
				local hasQuantifier = false;

				if (baseName.len() > 0) {

					// Check if the name starts with a number followed by space
					local numberEndPos = 0;
					local hasLeadingNumber = false;
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

					if (hasLeadingNumber && numberEndPos < baseName.len() && baseName.slice(numberEndPos, numberEndPos + 1) == " ") {
						hasQuantifier = true;
					} else {
						// Check for all quantifiers from our list
						foreach(prefix in quantifiers) {
							if (baseName.len() >= prefix.len() && baseName.slice(0, prefix.len()) == prefix) {
								hasQuantifier = true;
								break;
							}
						}
					}

					// If there's no quantifier, it's a champion
					if (!hasQuantifier) {
						isChampion = true;
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
            local count = group.count;
			if (group.count > 1) {
                if (!::Legends.Mod.ModSettings.getSetting("ExactEngageNumbers").getValue()) {
                    count = getEngagementNumbersName(count);
                }
				entry.text = count + (group.isChampion ? " [color=800808]Champion[/color] " : " ") + entry.text;
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

	function getEngagementNumbersName(count) {
		foreach(key, value in ::Const.Strings.EngageEnemyNumbers) {
			if (count >= value[0] && count <= value[1]) {
				return ::Const.Strings.EngageEnemyNumbersNames[key];
			}
		}
	}
}