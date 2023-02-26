class LeagueTable extends GSController
{
	names = [
		"company_value_table",
		"most_profitable_vehicle",
		"rail_infrastructure_efficiency",
		"road_infrastructure_efficiency",
		"canal_infrastructure_efficiency",
		"airport_infrastructure_efficiency",
		"most_profitable_train",
		"most_profitable_roadvehicle",
		"most_profitable_ship",
		"most_profitable_aircraft",
	];
	
	tables = [];

	constructor() {
		foreach (i, name in this.names) {
			tables.append({ name = "", id = null, el = array(GSCompany.COMPANY_LAST), val = {}, pct = {} });
			this.tables[i].name = name;
			for (local c_id = GSCompany.COMPANY_FIRST; c_id < GSCompany.COMPANY_LAST; c_id++) {
				this.tables[i].val.rawset(c_id, [ 0, SetText(GSText.STR_MAIN_EMPTY), SetText(GSText.STR_MAIN_EMPTY), [ GSLeagueTable.LINK_NONE, 0 ] ]);
				this.tables[i].pct.rawset(c_id, 0);
			}
		}
	}

	function Start();
	function Save();
	function Load(version, data);
}

function LeagueTable::Save()
{
	return {
		tables = this.tables
	};
}

function LeagueTable::Load(version, data)
{
	foreach (i, table in data.tables) {
		this.tables[i] = clone table;
	}
}

function LeagueTable::Start()
{
	local force_update = false;
	foreach (league in this.tables) {
		if (league.id == null) {
			league.id = GSLeagueTable.New(GSText(GetLeagueTitle(league.name)), GSText(GetLeagueHeader(league.name)), GSText(GetLeagueFooter(league.name)));
			for (local c_id = GSCompany.COMPANY_FIRST; c_id < GSCompany.COMPANY_LAST; c_id++) {
				if (GSCompany.ResolveCompanyID(c_id) != GSCompany.COMPANY_INVALID) {
					assert(league.el[c_id] == null);
					local c_val = GetLeagueVal(league.name, c_id);
					league.el[c_id] = GSLeagueTable.NewElement(league.id, Rating(c_val), c_id, GetText(Element(c_val)), GetText(Score(c_val), 0), LinkType(c_val), LinkTarget(c_val));
					force_update = true;
				}
			}
		}
	}

	while (true) {
		while (GSEventController.IsEventWaiting()) {
			local e = GSEventController.GetNextEvent();

			if (e.GetEventType() == GSEvent.ET_COMPANY_NEW) {
				local ec = GSEventCompanyNew.Convert(e);
				local c_id = ec.GetCompanyID();
				foreach (league in this.tables) {
					assert(league.el[c_id] == null);
					local c_val = GetLeagueVal(league.name, c_id);
					league.el[c_id] = GSLeagueTable.NewElement(league.id, Rating(c_val), c_id, GetText(Element(c_val)), GetText(Score(c_val), 0), LinkType(c_val), LinkTarget(c_val));
					force_update = true;
				}
			}

			if (e.GetEventType() == GSEvent.ET_COMPANY_BANKRUPT) {
				local ec = GSEventCompanyBankrupt.Convert(e);
				local c_id = ec.GetCompanyID();
				foreach (league in this.tables) {
					assert(league.el[c_id] != null);
					GSLeagueTable.RemoveElement(league.el[c_id]);
					league.el[c_id] = null;
					force_update = true;
				}
			}

			if (e.GetEventType() == GSEvent.ET_COMPANY_MERGER) {
				local ec = GSEventCompanyMerger.Convert(e);
				local c_id = ec.GetOldCompanyID();
				foreach (league in this.tables) {
					assert(league.el[c_id] != null);
					GSLeagueTable.RemoveElement(league.el[c_id]);
					league.el[c_id] = null;
					force_update = true;
				}
			}
		}

		foreach (window_number, league in this.tables) {
			if (!force_update && !GSGame.IsMultiplayer() && !GSWindow.IsOpen(GSWindow.WC_COMPANY_LEAGUE, window_number)) continue;
			local old_val = clone league.val;
			local old_pct = clone league.pct;
			foreach (c_id, c_val in league.val) {
				league.val.rawset(c_id, GetLeagueVal(league.name, c_id));
				GSAdmin.Send({ league_name = league.name, company = c_id, league_val = GetLeagueVal(league.name, c_id) });
			}
			
			local best_value = 0x8000000000000000;
			local worst_value = 0x7FFFFFFFFFFFFFFF;
			foreach (c_id, c_val in league.val) {
				if (league.el[c_id] != null) {
					local rating = Rating(c_val);
					if (rating > best_value) best_value = rating;
					if (rating < worst_value) worst_value = rating;
				}
			}
			local diff_value = best_value - worst_value;
			local diff_to_zero = 0 - worst_value;

			foreach (c_id, c_val in league.val) {
				if (league.el[c_id] != null) {
					local c_old_val = old_val.rawget(c_id);
					local old_rating = Rating(c_old_val);
					local new_rating = Rating(c_val);
					local c_old_pct = old_pct.rawget(c_id);
					local c_new_pct = 0;
					if (diff_to_zero >= 0) {
						c_new_pct = (new_rating + diff_to_zero) * 100 / (diff_value != 0 ? diff_value : 1);
					} else {
						c_new_pct = new_rating * 100 / (best_value != 0 ? best_value : 1);
					}
					league.pct.rawset(c_id, c_new_pct);
					if (force_update || new_rating != old_rating || c_new_pct != c_old_pct || TextChanged(Score(c_val), Score(c_old_val))) {
						GSLeagueTable.UpdateElementScore(league.el[c_id], new_rating, GetText(Score(c_val), c_new_pct));
					}
					if (force_update || TextChanged(Element(c_val), Element(c_old_val)) || LinkChanged(c_val, c_old_val)) {
						GSLeagueTable.UpdateElementData(league.el[c_id], c_id, GetText(Element(c_val)), LinkType(c_val), LinkTarget(c_val));
					}
				}
			}
		}
		force_update = false;
	}
}

function LeagueTable::LinkType(val)
{
	assert(typeof(val) == "array");
	assert(val.len() == 4);
	assert(typeof(val[3]) == "array");
	assert(val[3].len() == 2);
	assert(typeof(val[3][0]) == "integer");
	
	return val[3][0];
}

function LeagueTable::LinkTarget(val)
{
	assert(typeof(val) == "array");
	assert(val.len() == 4);
	assert(typeof(val[3]) == "array");
	assert(val[3].len() == 2);
	assert(typeof(val[3][1]) == "integer");
	
	return val[3][1];
}

function LeagueTable::LinkChanged(new_val, old_val)
{
	return LinkType(new_val) != LinkType(old_val) || LinkTarget(new_val) != LinkTarget(old_val);
}

function LeagueTable::Rating(val)
{
	assert(typeof(val) == "array");
	assert(val.len() == 4);
	assert(typeof(val[0]) == "integer");

	return val[0];
}

function LeagueTable::Score(val)
{
	assert(typeof(val) == "array");
	assert(val.len() == 4);
	assert(typeof(val[1]) == "table");

	return val[1];
}

function LeagueTable::Element(val)
{
	assert(typeof(val) == "array");
	assert(val.len() == 4);
	assert(typeof(val[2]) == "table");

	return val[2];
}

function LeagueTable::GetText(text, last_param = null)
{
	assert(typeof(text) == "table");
	assert(text.rawin("str"));
	assert(typeof(text.str) == "integer");
	assert(text.rawin("p"));
	assert(typeof(text.p) == "array");

	local ret = GSText(text.str);
	foreach (param in text.p) {
		if (typeof(param) == "table") {
			ret.AddParam(GetText(param))
		} else {;
			ret.AddParam(param);
		}
	}
	if (last_param != null) {
		assert(typeof(last_param) == "integer");
		ret.AddParam(last_param);
	}
	return ret;
}

function LeagueTable::SetText(string, params_array = [])
{
	assert(typeof(string) == "integer");
	assert(typeof(params_array) == "array");
	return {
		str = string,
		p = params_array
	};
}

function LeagueTable::TextChanged(new, old)
{
	assert(typeof(new) == "table");
	assert(new.rawin("str"));
	assert(typeof(new.str) == "integer");
	assert(new.rawin("p"));
	assert(typeof(new.p) == "array");
	assert(typeof(old) == "table");
	assert(old.rawin("str"));
	assert(typeof(old.str) == "integer");
	assert(old.rawin("p"));
	assert(typeof(old.p) == "array");

	if (new.str != old.str) return true;
	if (new.p.len() != old.p.len()) return true;
	foreach (i, p in new.p) {
		if (typeof(p) != typeof(old.p[i])) return true;
		if (typeof(p) == "table") {
			if (TextChanged(new.p[i], old.p[i])) return true;
		} else {
			if (p != old.p[i]) return true;
		}
	}
	return false;
}

function LeagueTable::GetLeagueVal(league_name, c_id)
{
	switch (league_name) {
		case "company_value_table":                  return GetCompanyValueTable_Val(c_id);
		case "most_profitable_vehicle":              return GetMostProfitableVehicle_Val(c_id);
		case "rail_infrastructure_efficiency":       return GetRailInfrastructureEfficiency_Val(c_id);
		case "road_infrastructure_efficiency":       return GetRoadInfrastructureEfficiency_Val(c_id);
		case "canal_infrastructure_efficiency":      return GetCanalInfrastructureEfficiency_Val(c_id);
		case "airport_infrastructure_efficiency":    return GetAirportInfrastructureEfficiency_Val(c_id);
		case "most_profitable_train":                return GetMostProfitableTrain_Val(c_id);
		case "most_profitable_roadvehicle":          return GetMostProfitableRoadVehicle_Val(c_id);
		case "most_profitable_ship":                 return GetMostProfitableShip_Val(c_id);
		case "most_profitable_aircraft":             return GetMostProfitableAircraft_Val(c_id);
		default: assert(false);
	}
}

function LeagueTable::GetLeagueScoreString(league_name)
{
	switch (league_name) {
		case "company_value_table":                  return GetCompanyValueTable_ScoreString();
		case "most_profitable_vehicle":              return GetMostProfitableVehicle_ScoreString();
		case "rail_infrastructure_efficiency":       return GetRailInfrastructureEfficiency_ScoreString();
		case "road_infrastructure_efficiency":       return GetRoadInfrastructureEfficiency_ScoreString();
		case "canal_infrastructure_efficiency":      return GetCanalInfrastructureEfficiency_ScoreString();
		case "airport_infrastructure_efficiency":    return GetAirportInfrastructureEfficiency_ScoreString();
		case "most_profitable_train":                return GetMostProfitableTrain_ScoreString();
		case "most_profitable_roadvehicle":          return GetMostProfitableRoadVehicle_ScoreString();
		case "most_profitable_ship":                 return GetMostProfitableShip_ScoreString();
		case "most_profitable_aircraft":             return GetMostProfitableAircraft_ScoreString();
		default: assert(false);
	}
}

function LeagueTable::GetLeagueTitle(league_name)
{
	switch (league_name) {
		case "company_value_table":                  return GetCompanyValueTable_TitleString();
		case "most_profitable_vehicle":              return GetMostProfitableVehicle_TitleString();
		case "rail_infrastructure_efficiency":       return GetRailInfrastructureEfficiency_TitleString();
		case "road_infrastructure_efficiency":       return GetRoadInfrastructureEfficiency_TitleString();
		case "canal_infrastructure_efficiency":      return GetCanalInfrastructureEfficiency_TitleString();
		case "airport_infrastructure_efficiency":    return GetAirportInfrastructureEfficiency_TitleString();
		case "most_profitable_train":                return GetMostProfitableTrain_TitleString();
		case "most_profitable_roadvehicle":          return GetMostProfitableRoadVehicle_TitleString();
		case "most_profitable_ship":                 return GetMostProfitableShip_TitleString();
		case "most_profitable_aircraft":             return GetMostProfitableAircraft_TitleString();
		default: assert(false);
	}
}

function LeagueTable::GetLeagueHeader(league_name)
{
	switch (league_name) {
		case "company_value_table":                  return GetCompanyValueTable_HeaderString();
		case "most_profitable_vehicle":              return GetMostProfitableVehicle_HeaderString();
		case "rail_infrastructure_efficiency":       return GetRailInfrastructureEfficiency_HeaderString();
		case "road_infrastructure_efficiency":       return GetRoadInfrastructureEfficiency_HeaderString();
		case "canal_infrastructure_efficiency":      return GetCanalInfrastructureEfficiency_HeaderString();
		case "airport_infrastructure_efficiency":    return GetAirportInfrastructureEfficiency_HeaderString();
		case "most_profitable_train":                return GetMostProfitableTrain_HeaderString();
		case "most_profitable_roadvehicle":          return GetMostProfitableRoadVehicle_HeaderString();
		case "most_profitable_ship":                 return GetMostProfitableShip_HeaderString();
		case "most_profitable_aircraft":             return GetMostProfitableAircraft_HeaderString();
		default: assert(false);
	}
}

function LeagueTable::GetLeagueFooter(league_name)
{
	switch (league_name) {
		case "company_value_table":                  return GetCompanyValueTable_FooterString();
		case "most_profitable_vehicle":              return GetMostProfitableVehicle_FooterString();
		case "rail_infrastructure_efficiency":       return GetRailInfrastructureEfficiency_FooterString();
		case "road_infrastructure_efficiency":       return GetRoadInfrastructureEfficiency_FooterString();
		case "canal_infrastructure_efficiency":      return GetCanalInfrastructureEfficiency_FooterString();
		case "airport_infrastructure_efficiency":    return GetAirportInfrastructureEfficiency_FooterString();
		case "most_profitable_train":                return GetMostProfitableTrain_FooterString();
		case "most_profitable_roadvehicle":          return GetMostProfitableRoadVehicle_FooterString();
		case "most_profitable_ship":                 return GetMostProfitableShip_FooterString();
		case "most_profitable_aircraft":             return GetMostProfitableAircraft_FooterString();
		default: assert(false);
	}
}

require("company_value_table.nut");
require("most_profitable_vehicle.nut");
require("rail_infrastructure_efficiency.nut");
require("road_infrastructure_efficiency.nut");
require("canal_infrastructure_efficiency.nut");
require("airport_infrastructure_efficiency.nut");
require("most_profitable_train.nut");
require("most_profitable_roadvehicle.nut");
require("most_profitable_ship.nut");
require("most_profitable_aircraft.nut");
