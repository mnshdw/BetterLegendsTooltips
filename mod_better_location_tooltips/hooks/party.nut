
::ModBetterLocationTooltips.HooksMod.hook("scripts/entity/world/party", function(q) {
	q.getTooltip = @(__original) function() {
		local tooltip = __original();

		return ::ModBetterLocationTooltips.TooltipHelper.processTooltip(tooltip);
	};
});
