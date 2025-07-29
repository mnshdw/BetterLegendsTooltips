::ModBetterLegendsTooltips.Helper <- {
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

		// Extract text entries with icons
		local textEntries = [];
		foreach(index, entry in tooltip) {
			if ("type" in entry && entry.type == "text" && "text" in entry && "icon" in entry) {
				textEntries.push(entry);
			}
		}

		local processedEntries = processEntityGroup(
			textEntries,
			function(entry) { return entry.icon; },
			function(entry) { return entry.text; },
			function(entry, newText) { entry.text = newText; },
			null, // Use default quantifier-based champion detection for tooltips
			true  // Use color formatting for tooltips
		);

		// Build new tooltip with processed entries and non-text entries
		local newTooltip = [];
		foreach(entry in processedEntries) {
			newTooltip.push(entry);
		}

		// Add non-text entries back to the tooltip
		foreach(index, entry in tooltip) {
			if (!("type" in entry && entry.type == "text" && "text" in entry && "icon" in entry)) {
				newTooltip.push(entry);
			}
		}

		return newTooltip;
	}

	function processWorldCombatDialog(_entities) {

		if (::ModBetterLegendsTooltips.Enabled == false) {
			return _entities;
		}

		// Extract entities with Icon and Name
		local entities = [];
		foreach(index, entry in _entities) {
			if ("Icon" in entry && "Name" in entry) {
				entities.push(entry);
			}
		}

		return processEntityGroup(
			entities,
			function(entry) { return entry.Icon; },
			function(entry) { return entry.Name; },
			function(entry, newName) { entry.Name = newName; },
			function(entry) { return "Overlay" in entry && typeof entry.Overlay == "string" && entry.Overlay == "icons/miniboss.png"; },
			false // World combat dialog doesn't use XBBCODE (yet) so colors don't work
		);
	}

	function processEntityGroup(entities, getIcon, getName, setName, championDetectionFn = null, useColorFormatting = true) {

		// Usually ennemy troops have a "quantifier" prefix that indicates how many of them are there.
		// Depending on Legends setting "Exact engagement numbers", this prefix can be a number or a word,
		// for example:
		// - "A Desert Stalker"
		// - "Some Orc Warriors"
		// - "6 Barbarian Chosen"
		// We detect champions by checking that the name of the entity does *not* start with such quantifiers.

		// First create a list of all quantifier prefixes
		local quantifiers = ["A ", "An "];
		foreach (key, value in ::Const.Strings.EngageEnemyNumbersNames) {
			quantifiers.push(value + " ");
		}

		// Entries look like this:
		// Entry #0 key=Icon, value=slave_orientation
		// Entry #0 key=Overlay, value=(null : 0x00000000)
		// Entry #0 key=Name, value=2 Indebted

		// Iterate through the entries and group them by icon and name
		local groupedEntities = {};
		foreach(index, entity in entities) {
			local icon = getIcon(entity);
			local baseName = getName(entity);

			if (icon != null && baseName != null) {
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

				// Special case: Fortifications is terrain information, never a champion
				if (baseName == "Fortifications") {
					isChampion = false;
				} else if (championDetectionFn != null) {
					// World combat dialog can detect champions by checking the Overlay field
					isChampion = championDetectionFn(entity);
				}

				// If MergeNamedEnemies is enabled and this is a champion, try to determine the base name of the entity
				if (::ModBetterLegendsTooltips.MergeNamedEnemies && isChampion) {
					local iconName = icon;

					// Extract the entity ID from the icon path
					// This has to work for both tooltip icons (which contain a path like
					// "ui/orientation/orc_03_orientation.png") and world combat dialog icons
					// (which only contain the entity ID like "orc_03_orientation").
					if (typeof icon == "string") {
						local lastSlash = icon.find("/");
						while (lastSlash != null) {
							local nextSlash = icon.find("/", lastSlash + 1);
							if (nextSlash == null) {
								break;
							}
							lastSlash = nextSlash;
						}

						if (lastSlash != null) {
							local lastDot = icon.find(".", lastSlash);
							if (lastDot != null) {
								iconName = icon.slice(lastSlash + 1, lastDot);
							} else {
								iconName = icon.slice(lastSlash + 1);
							}
						} else {
							local lastDot = icon.find(".");
							if (lastDot != null) {
								iconName = icon.slice(0, lastDot);
							} else {
								iconName = icon;
							}
						}
					}

					local entityIndex = ::Const.EntityIcon.find(iconName);
					if (entityIndex != null && entityIndex in ::Const.Strings.EntityName) {
						baseName = ::Const.Strings.EntityName[entityIndex];
						// For champions, replace the name (eg. "Sir Geofram") with the base name (eg. "Sellsword")
						if (isChampion) {
							setName(entity, baseName);
						}
					}
				}

				// Group by icon and base name
				local key = icon + "|" + baseName + "|" + (isChampion ? "champion" : "normal");
				if (key in groupedEntities) {
					groupedEntities[key].count++;
				} else {
					groupedEntities[key] <- {
						count = 1,
						entity = entity,
						isChampion = isChampion
					};
				}
			}
		}

		// Build result array with grouped entities
		local result = [];
		foreach(key, group in groupedEntities) {
			local entity = group.entity;
			local count = group.count;
			local currentName = getName(entity);

			if (group.count > 1) {
				if (!::Legends.Mod.ModSettings.getSetting("ExactEngageNumbers").getValue()) {
					count = getEngagementNumbersName(count);
				}
				local championLabel = group.isChampion ? (useColorFormatting ? " [color=800808]Champion[/color] " : " Champion ") : " ";
				setName(entity, count + championLabel + currentName);
			} else if (group.isChampion) {
				local championLabel = useColorFormatting ? "[color=800808]Champion[/color] " : "Champion ";
				setName(entity, championLabel + currentName);
			}
			result.push(entity);
		}

		// Sort the entries by icon and ensure non-champions come before champions
		result.sort(function(a, b) {
			local nameA = getName(a);
			local nameB = getName(b);

			// Fortifications always comes first
			if (nameA == "Fortifications" && nameB != "Fortifications") {
				return -1;
			}
			if (nameB == "Fortifications" && nameA != "Fortifications") {
				return 1;
			}
			if (nameA == "Fortifications" && nameB == "Fortifications") {
				return 0;
			}

			local iconA = getIcon(a);
			local iconB = getIcon(b);
			if (iconA != null && iconB != null) {
				if (iconA == iconB) {
					local aIsChampion = nameA.find("Champion[/color]") != null || nameA.find("Champion ") != null;
					local bIsChampion = nameB.find("Champion[/color]") != null || nameB.find("Champion ") != null;
					return aIsChampion && !bIsChampion ? 1 : (!aIsChampion && bIsChampion ? -1 : 0);
				}
				return iconA < iconB ? -1 : (iconA > iconB ? 1 : 0);
			}
			return 0;
		});

		return result;
	}

	function getEngagementNumbersName(count) {
		foreach(key, value in ::Const.Strings.EngageEnemyNumbers) {
			if (count >= value[0] && count <= value[1]) {
				return ::Const.Strings.EngageEnemyNumbersNames[key];
			}
		}
	}
}
