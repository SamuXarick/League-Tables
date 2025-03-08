class LeagueTables extends GSController
{
	static names = [
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
		"income_table",
		"transport_infrastructure_efficiency",
	];

	tables = [];
	async_mode = null;
	update_mode = null;
	timer = null;

	force_update = null;

	constructor()
	{
		foreach (i, league in this.names) {
			tables.append({ name = league, id = null, element = array(GSCompany.COMPANY_LAST), stats = {}, percentage = {} });
			for (local c_id = GSCompany.COMPANY_FIRST; c_id < GSCompany.COMPANY_LAST; c_id++) {
				this.tables[i].stats.rawset(c_id, [ 0, SetText(GSText.STR_MAIN_EMPTY), SetText(GSText.STR_MAIN_EMPTY), [ GSLeagueTable.LINK_NONE, 0 ] ]);
				this.tables[i].percentage.rawset(c_id, 0);
			}
		}
		this.async_mode = GSController.GetSetting("async_mode") != 0;
		this.update_mode = GSController.GetSetting("update_mode");
		this.timer = GSDate.GetCurrentDate();

		this.force_update = false;
	}
}

function LeagueTables::Start()
{
	InitializeTables();

	do {
		this.async_mode = GSController.GetSetting("async_mode") != 0;
		this.update_mode = GSController.GetSetting("update_mode");

		HandleEvents();
		UpdateTables(UpdateTimer());
	} while (true);
}

function LeagueTables::InitializeTables()
{
	local async = this.async_mode && !GSGame.IsMultiplayer();
	async = GSAsyncMode(async);

	foreach (league in this.tables) {
		if (league.id == null) {
			league.id = GSLeagueTable.New(GSText(TitleString(league.name)), GSText(HeaderString(league.name)), GSText(FooterString(league.name)));
			for (local c_id = GSCompany.COMPANY_FIRST; c_id < GSCompany.COMPANY_LAST; c_id++) {
				if (GSCompany.ResolveCompanyID(c_id) != GSCompany.COMPANY_INVALID) {
					assert(league.element[c_id] == null);
					local c_stats = Stats(league.name, c_id);
					league.element[c_id] = GSLeagueTable.NewElement(league.id, Rating(c_stats), c_id, GetText(Element(c_stats)), GetText(Score(c_stats), 0), LinkType(c_stats), LinkTarget(c_stats));
					this.force_update = true;
				}
			}
		}
	}
}

function LeagueTables::HandleEvents()
{
	local async = this.async_mode && !GSGame.IsMultiplayer();
	async = GSAsyncMode(async);

	while (GSEventController.IsEventWaiting()) {
		local e = GSEventController.GetNextEvent();

		if (e.GetEventType() == GSEvent.ET_COMPANY_NEW) {
			local ec = GSEventCompanyNew.Convert(e);
			local c_id = ec.GetCompanyID();
			foreach (league in this.tables) {
				if (league.element[c_id] != null) continue;
				local c_stats = Stats(league.name, c_id);
				league.element[c_id] = GSLeagueTable.NewElement(league.id, Rating(c_stats), c_id, GetText(Element(c_stats)), GetText(Score(c_stats), 0), LinkType(c_stats), LinkTarget(c_stats));
				this.force_update = true;
			}
		}

		if (e.GetEventType() == GSEvent.ET_COMPANY_BANKRUPT) {
			local ec = GSEventCompanyBankrupt.Convert(e);
			local c_id = ec.GetCompanyID();
			foreach (league in this.tables) {
				assert(league.element[c_id] != null);
				assert(GSLeagueTable.RemoveElement(league.element[c_id]));
				league.element[c_id] = null;
				this.force_update = true;
			}
		}

		if (e.GetEventType() == GSEvent.ET_COMPANY_MERGER) {
			local ec = GSEventCompanyMerger.Convert(e);
			local c_id = ec.GetOldCompanyID();
			foreach (league in this.tables) {
				assert(league.element[c_id] != null);
				assert(GSLeagueTable.RemoveElement(league.element[c_id]));
				league.element[c_id] = null;
				this.force_update = true;
			}
		}
	}
}

function LeagueTables::UpdateTimer()
{
	GSController.Sleep(1);

	local time = GSDate.GetCurrentDate();

	if (this.update_mode != 0) {
		local prev_year = GSDate.GetYear(this.timer);
		local cur_year = GSDate.GetYear(time);
		if (cur_year == prev_year && this.update_mode == 3) return false;

		local prev_month = GSDate.GetMonth(this.timer);
		local cur_month = GSDate.GetMonth(time);
		if (cur_month == prev_month && this.update_mode == 2) return false;

		local prev_day = GSDate.GetDayOfMonth(this.timer);
		local cur_day = GSDate.GetDayOfMonth(time);
		if (cur_day == prev_day && this.update_mode == 1) return false;
	}

	this.timer = time;
	return true;
}

function LeagueTables::UpdateTables(update)
{
	local async = this.async_mode;
	async = GSAsyncMode(async);

	foreach (window_number, league in this.tables) {
		if (!update || (this.update_mode == 0 && !this.force_update && !GSGame.IsMultiplayer() && !GSWindow.IsOpen(GSWindow.WC_COMPANY_LEAGUE, window_number))) continue;

		local old_stats = clone league.stats;
		local old_percentage = clone league.percentage;
		foreach (c_id, _ in league.stats) {
			local c_stats = Stats(league.name, c_id);
			league.stats.rawset(c_id, c_stats);
			assert(GSAdmin.Send({ league_name = league.name, company = c_id, company_stats = c_stats }));
		}

		local best_value = 0x8000000000000000;
		local worst_value = 0x7FFFFFFFFFFFFFFF;
		foreach (c_id, c_stats in league.stats) {
			if (league.element[c_id] != null) {
				local rating = Rating(c_stats);
				if (rating > best_value) best_value = rating;
				if (rating < worst_value) worst_value = rating;
			}
		}
		local diff_value = best_value - worst_value;
		local diff_to_zero = 0 - worst_value;

		foreach (c_id, c_stats in league.stats) {
			if (league.element[c_id] != null) {
				local c_old_stats = old_stats.rawget(c_id);
				local old_rating = Rating(c_old_stats);
				local new_rating = Rating(c_stats);
				local c_old_percentage = old_percentage.rawget(c_id);
				local c_new_percentage = 0;
				if (diff_to_zero >= 0) {
					c_new_percentage = (new_rating + diff_to_zero) * 100 / (diff_value != 0 ? diff_value : 1);
				} else {
					c_new_percentage = new_rating * 100 / (best_value != 0 ? best_value : 1);
				}
				league.percentage.rawset(c_id, c_new_percentage);
				if (this.force_update || (update && (new_rating != old_rating || c_new_percentage != c_old_percentage || TextChanged(Score(c_stats), Score(c_old_stats))))) {
					GSLeagueTable.UpdateElementScore(league.element[c_id], new_rating, GetText(Score(c_stats), c_new_percentage));
				}
				if (this.force_update || (update && (TextChanged(Element(c_stats), Element(c_old_stats)) || LinkChanged(c_stats, c_old_stats)))) {
					GSLeagueTable.UpdateElementData(league.element[c_id], c_id, GetText(Element(c_stats)), LinkType(c_stats), LinkTarget(c_stats));
				}
			}
		}
	}

	this.force_update = false;
}

function LeagueTables::LinkType(stats)
{
	assert(typeof(stats) == "array");
	assert(stats.len() == 4);
	assert(typeof(stats[3]) == "array");
	assert(stats[3].len() == 2);
	assert(typeof(stats[3][0]) == "integer");

	return stats[3][0];
}

function LeagueTables::LinkTarget(stats)
{
	assert(typeof(stats) == "array");
	assert(stats.len() == 4);
	assert(typeof(stats[3]) == "array");
	assert(stats[3].len() == 2);
	assert(typeof(stats[3][1]) == "integer");

	return stats[3][1];
}

function LeagueTables::LinkChanged(new_stats, old_stats)
{
	return LinkType(new_stats) != LinkType(old_stats) || LinkTarget(new_stats) != LinkTarget(old_stats);
}

function LeagueTables::Rating(stats)
{
	assert(typeof(stats) == "array");
	assert(stats.len() == 4);
	assert(typeof(stats[0]) == "integer");

	return stats[0];
}

function LeagueTables::Score(stats)
{
	assert(typeof(stats) == "array");
	assert(stats.len() == 4);
	assert(typeof(stats[1]) == "table");

	return stats[1];
}

function LeagueTables::Element(stats)
{
	assert(typeof(stats) == "array");
	assert(stats.len() == 4);
	assert(typeof(stats[2]) == "table");

	return stats[2];
}

function LeagueTables::GetText(text, last_param = null)
{
	assert(typeof(text) == "table");
	assert(text.rawin("string"));
	assert(typeof(text.string) == "integer");
	assert(text.rawin("params"));
	assert(typeof(text.params) == "array");

	local gs_text = GSText(text.string);
	foreach (param in text.params) {
		if (typeof(param) == "table") {
			gs_text.AddParam(GetText(param));
		} else {
			gs_text.AddParam(param);
		}
	}

	if (last_param != null) {
		assert(typeof(last_param) == "integer");
		gs_text.AddParam(last_param);
	}

	return gs_text;
}

function LeagueTables::SetText(string, params_array = [])
{
	assert(typeof(string) == "integer");
	assert(typeof(params_array) == "array");

	return {
		string = string,
		params = params_array
	};
}

function LeagueTables::TextChanged(new, old)
{
	assert(typeof(new) == "table");
	assert(new.rawin("string"));
	assert(typeof(new.string) == "integer");
	assert(new.rawin("params"));
	assert(typeof(new.params) == "array");
	assert(typeof(old) == "table");
	assert(old.rawin("string"));
	assert(typeof(old.string) == "integer");
	assert(old.rawin("params"));
	assert(typeof(old.params) == "array");

	if (new.string != old.string) return true;
	if (new.params.len() != old.params.len()) return true;
	foreach (i, params in new.params) {
		if (typeof(params) != typeof(old.params[i])) return true;
		if (typeof(params) == "table") {
			if (TextChanged(new.params[i], old.params[i])) return true;
		} else {
			if (params != old.params[i]) return true;
		}
	}

	return false;
}

function LeagueTables::Stats(league_name, c_id)
{
	switch (league_name) {
		case "company_value_table":                  return GetCompanyValueTable_Stats(c_id);
		case "most_profitable_vehicle":              return GetMostProfitableVehicle_Stats(c_id);
		case "rail_infrastructure_efficiency":       return GetRailInfrastructureEfficiency_Stats(c_id);
		case "road_infrastructure_efficiency":       return GetRoadInfrastructureEfficiency_Stats(c_id);
		case "canal_infrastructure_efficiency":      return GetCanalInfrastructureEfficiency_Stats(c_id);
		case "airport_infrastructure_efficiency":    return GetAirportInfrastructureEfficiency_Stats(c_id);
		case "most_profitable_train":                return GetMostProfitableTrain_Stats(c_id);
		case "most_profitable_roadvehicle":          return GetMostProfitableRoadVehicle_Stats(c_id);
		case "most_profitable_ship":                 return GetMostProfitableShip_Stats(c_id);
		case "most_profitable_aircraft":             return GetMostProfitableAircraft_Stats(c_id);
		case "income_table":                         return GetIncomeTable_Stats(c_id);
		case "transport_infrastructure_efficiency":  return GetTransportInfrastructureEfficiency_Stats(c_id);
		default: throw "Invalid league_name: " + league_name;
	}
}

function LeagueTables::ScoreString(league_name)
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
		case "income_table":                         return GetIncomeTable_ScoreString();
		case "transport_infrastructure_efficiency":  return GetTransportInfrastructureEfficiency_ScoreString();
		default: throw "Invalid league_name: " + league_name;
	}
}

function LeagueTables::TitleString(league_name)
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
		case "income_table":                         return GetIncomeTable_TitleString();
		case "transport_infrastructure_efficiency":  return GetTransportInfrastructureEfficiency_TitleString();
		default: throw "Invalid league_name: " + league_name;
	}
}

function LeagueTables::HeaderString(league_name)
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
		case "income_table":                         return GetIncomeTable_HeaderString();
		case "transport_infrastructure_efficiency":  return GetTransportInfrastructureEfficiency_HeaderString();
		default: throw "Invalid league_name: " + league_name;
	}
}

function LeagueTables::FooterString(league_name)
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
		case "income_table":                         return GetIncomeTable_FooterString();
		case "transport_infrastructure_efficiency":  return GetTransportInfrastructureEfficiency_FooterString();
		default: throw "Invalid league_name: " + league_name;
	}
}

require("saveload.nut");

require("leagues/company_value_table.nut");
require("leagues/most_profitable_vehicle.nut");
require("leagues/rail_infrastructure_efficiency.nut");
require("leagues/road_infrastructure_efficiency.nut");
require("leagues/canal_infrastructure_efficiency.nut");
require("leagues/airport_infrastructure_efficiency.nut");
require("leagues/most_profitable_train.nut");
require("leagues/most_profitable_roadvehicle.nut");
require("leagues/most_profitable_ship.nut");
require("leagues/most_profitable_aircraft.nut");
require("leagues/income_table.nut");
require("leagues/transport_infrastructure_efficiency.nut");
