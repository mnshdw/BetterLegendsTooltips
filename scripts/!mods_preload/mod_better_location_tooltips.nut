::ModBetterLocationTooltips <- {
	ID = "mod_better_location_tooltips",
	Name = "Better Location Tooltips",
	Version = "1.0.0",
	CollapseNamedEnemies = true,
};

::ModBetterLocationTooltips.HooksMod <- ::Hooks.register(::ModBetterLocationTooltips.ID, ::ModBetterLocationTooltips.Version, ::ModBetterLocationTooltips.Name);

::ModBetterLocationTooltips.HooksMod.require("mod_msu >= 1.2.7", "mod_modern_hooks >= 0.5.4");

::ModBetterLocationTooltips.HooksMod.queue(">mod_msu", function() {
	::ModBetterLocationTooltips.Mod <- ::MSU.Class.Mod(::ModBetterLocationTooltips.ID, ::ModBetterLocationTooltips.Version, ::ModBetterLocationTooltips.Name);

	// Register with MSU so people know to update
	::ModBetterLocationTooltips.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/mnshdw/BetterLocationTooltips");::ModBetterLocationTooltips.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	// MSU config page
	local page = ::ModBetterLocationTooltips.Mod.ModSettings.addPage("Better Location Tooltips");
	page.addTitle("title", "You can tweak how location tooltips appear in game.");
	page.addDivider("divider");
	local settingCollapseNamedEnemies = page.addBooleanSetting(
		"CollapseNamedEnemies",
		true,
		"Collapse Named Enemies",
		"When enabled, ennemy champions with unique names will be merged together."
	);
	settingCollapseNamedEnemies.addCallback(function(_value) {
		::ModBetterLocationTooltips.CollapseNamedEnemies = _value;
	});

	::include("mod_better_location_tooltips/hooks/location");

}, ::Hooks.QueueBucket.Normal);