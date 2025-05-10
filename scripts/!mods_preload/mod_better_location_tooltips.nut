::ModBetterLocationTooltips <- {
	ID = "mod_better_location_tooltips",
	Name = "Better Location Tooltips",
	Version = "1.0.0",
	Enabled = true
	MergeNamedEnemies = true,
};

::ModBetterLocationTooltips.HooksMod <- ::Hooks.register(::ModBetterLocationTooltips.ID, ::ModBetterLocationTooltips.Version, ::ModBetterLocationTooltips.Name);

::ModBetterLocationTooltips.HooksMod.require("mod_msu >= 1.2.7", "mod_modern_hooks >= 0.5.4");

::ModBetterLocationTooltips.HooksMod.queue(">mod_msu", function() {
	::ModBetterLocationTooltips.Mod <- ::MSU.Class.Mod(::ModBetterLocationTooltips.ID, ::ModBetterLocationTooltips.Version, ::ModBetterLocationTooltips.Name);

	// Register with MSU so people know to update
	::ModBetterLocationTooltips.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/mnshdw/BetterLocationTooltips");::ModBetterLocationTooltips.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	// MSU config page
	local page = ::ModBetterLocationTooltips.Mod.ModSettings.addPage("Better Location Tooltips");
	local settingEnabled = page.addBooleanSetting(
		"Enabled",
		true,
		"Enabled",
		"When enabled, the mod will try to improve location and enemy party tooltips. If you encounter any issues, or want vanilla behaviour, just disable this."
	);
	settingEnabled.addCallback(function(_value) {
		::ModBetterLocationTooltips.Enabled = _value;
	});
	page.addDivider("divider");
	local settingMergeNamedEnemies = page.addBooleanSetting(
		"MergeNamedEnemies",
		true,
		"Merge Named Enemies",
		"When enabled, ennemy champions with unique names will be merged together. For example, 'The Mountain' and 'The Scourge' become '2 [color=800808]Champion[/color] Hedge Knights'."
	);
	settingMergeNamedEnemies.addCallback(function(_value) {
		::ModBetterLocationTooltips.MergeNamedEnemies = _value;
	});

	::include("mod_better_location_tooltips/config/helper");
	::include("mod_better_location_tooltips/hooks/location");
	::include("mod_better_location_tooltips/hooks/party");

}, ::Hooks.QueueBucket.Normal);