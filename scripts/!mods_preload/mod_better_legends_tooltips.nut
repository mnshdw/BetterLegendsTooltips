::ModBetterLegendsTooltips <- {
	ID = "mod_better_legends_tooltips",
	Name = "Better Legends Tooltips",
	Version = "1.0.2",
	Enabled = true,
	MergeNamedEnemies = false,
};

::ModBetterLegendsTooltips.HooksMod <- ::Hooks.register(::ModBetterLegendsTooltips.ID, ::ModBetterLegendsTooltips.Version, ::ModBetterLegendsTooltips.Name);

::ModBetterLegendsTooltips.HooksMod.require("mod_msu >= 1.2.7", "mod_modern_hooks >= 0.5.4");

::ModBetterLegendsTooltips.HooksMod.queue(">mod_msu", ">mod_legends", ">mod_sellswords", ">mod_ROTUC", function() {
	::ModBetterLegendsTooltips.Mod <- ::MSU.Class.Mod(::ModBetterLegendsTooltips.ID, ::ModBetterLegendsTooltips.Version, ::ModBetterLegendsTooltips.Name);

	// Register with MSU so people know to update
	::ModBetterLegendsTooltips.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/mnshdw/BetterLegendsTooltips");
	::ModBetterLegendsTooltips.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	// MSU config page
	local page = ::ModBetterLegendsTooltips.Mod.ModSettings.addPage("Better Legends Tooltips");
	local settingEnabled = page.addBooleanSetting(
		"Enabled",
		true,
		"Enabled",
		"When enabled, the mod will try to improve location and enemy party tooltips. If you encounter any issues, or want vanilla behaviour, just disable this."
	);
	settingEnabled.addCallback(function(_value) {
		::ModBetterLegendsTooltips.Enabled = _value;
	});
	page.addDivider("divider");
	local settingMergeNamedEnemies = page.addBooleanSetting(
		"MergeNamedEnemies",
		true,
		"Merge Named Enemies",
		"When enabled, ennemy champions with unique names will be merged together. For example, 'The Mountain' and 'The Scourge' should become '2 [color=800808]Champion[/color] Hedge Knights'. This may not work properly when plurals are involved (eg. Billman vs Billmen, A Wardog vs Wardog). Report any issue you see."
	);
	settingMergeNamedEnemies.addCallback(function(_value) {
		::ModBetterLegendsTooltips.MergeNamedEnemies = _value;
	});

	::include("mod_better_legends_tooltips/config/helper");
	::include("mod_better_legends_tooltips/hooks/location");
	::include("mod_better_legends_tooltips/hooks/party");
	::include("mod_better_legends_tooltips/hooks/ui/screens/world/world_combat_dialog");

}, ::Hooks.QueueBucket.Normal);
