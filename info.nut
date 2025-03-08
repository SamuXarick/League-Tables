class LeagueTables extends GSInfo
{
	function GetAuthor()        { return "Samu"; }
	function GetName()          { return "League Tables"; }
	function GetDescription()   { return "Various company based league tables."; }
	function GetVersion()       { return 3; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "08-03-2025"; }
	function GetShortName()     { return "LeTa"; }
	function CreateInstance()   { return "LeagueTables"; }
	function GetAPIVersion()    { return "14"; }
	function GetURL()           { return "https://github.com/SamuXarick/League-Tables"; }

	function GetSettings()
	{
		AddSetting({
			name = "update_mode",
			description = "Table update mode",
			min_value = 0,
			max_value = 3,
			default_value = 0,
			flags = GSInfo.CONFIG_INGAME,
		});

		AddLabels("update_mode", {
			_0 = "Every tick",
			_1 = "Every day",
			_2 = "Every month",
			_3 = "Every year",
		});

		AddSetting({
			name = "async_mode",
			description = "Asynchronous mode",
			default_value = 1,
			flags = GSInfo.CONFIG_BOOLEAN | GSInfo.CONFIG_INGAME,
		});
	}
}

RegisterGS(LeagueTables());
