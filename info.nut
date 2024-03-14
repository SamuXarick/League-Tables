class LeagueTable extends GSInfo
{
	function GetAuthor()        { return "Samu"; }
	function GetName()          { return "League Tables"; }
	function GetDescription()   { return "Various company based league tables."; }
	function GetVersion()       { return 1; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "14-03-2024"; }
	function GetShortName()     { return "LeTa"; }
	function CreateInstance()   { return "LeagueTable"; }
	function GetAPIVersion()    { return "13"; }
	function GetURL()           { return "https://github.com/SamuXarick/League-Tables"; }
}

RegisterGS(LeagueTable());
