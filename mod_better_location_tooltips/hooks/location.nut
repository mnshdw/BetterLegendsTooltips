::ModBetterLocationTooltips.HooksMod.hook("scripts/entity/world/location", function(q) {
	q.getTooltip = @(__original) function() {
		local tooltip = __original();

		// Show defenders if not already showing
		if (!this.m.IsShowingDefenders) {
			this.m.IsShowingDefenders = true;
		}

		return ::ModBetterLocationTooltips.TooltipHelper.processTooltip(tooltip);
	};
});
