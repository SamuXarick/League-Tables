class LeagueTable extends GSInfo
{
	function GetAuthor()        { return "Samu"; }
	function GetName()          { return "League Tables"; }
	function GetDescription()   { return "Various company based league tables."; }
	function GetVersion()       { return 1; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "11-02-2023"; }
	function GetShortName()     { return "LeTa"; }
	function CreateInstance()   { return "LeagueTable"; }
	function GetAPIVersion()    { return "13"; }
}

RegisterGS(LeagueTable());
