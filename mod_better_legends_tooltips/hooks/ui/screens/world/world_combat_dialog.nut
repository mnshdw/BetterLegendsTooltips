::ModBetterLegendsTooltips.HooksMod.hook("scripts/ui/screens/world/world_combat_dialog", function(q) {

	q.show = @(__original) function(_entities, _allyBanners, _enemyBanners, _allowDisengage, _allowFormationPicking, _text, _image, _disengageText = "Cancel") {
		local updated_entities =  ::ModBetterLegendsTooltips.Helper.processWorldCombatDialog(_entities);
		__original(updated_entities, _allyBanners, _enemyBanners, _allowDisengage, _allowFormationPicking, _text, _image, _disengageText);
	};

});
