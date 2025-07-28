
::ModBetterLegendsTooltips.HooksMod.hook("scripts/entity/world/party", function(q) {
	q.getTooltip = @(__original) function() {
		local tooltip = __original();

		return ::ModBetterLegendsTooltips.Helper.processTooltip(tooltip);
	};
});
