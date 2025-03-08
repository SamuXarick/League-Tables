function LeagueTables::GetCanalInfrastructureEfficiency_Stats(company)
{
	local rating = 0;
	local score_text = SetText(GetCanalInfrastructureEfficiency_ScoreString(), [ 0, 0, 0, 0 ]);
	local element_text = SetText(GSText.STR_CANAL_INFRASTRUCTURE_EFFICIENCY_NONE);
	local link_info = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);

		local infrastructure_count = GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_CANAL);

		local vehicle_list = GSVehicleList();
		vehicle_list.Valuate(GSVehicle.GetVehicleType);
		vehicle_list.KeepValue(GSVehicle.VT_WATER);
		local get_profits = function(vehicle_id) { return GSVehicle.GetProfitLastYear(vehicle_id) + GSVehicle.GetProfitThisYear(vehicle_id); };
		vehicle_list.Valuate(get_profits);

		local maintenance_cost = GSInfrastructure.GetMonthlyInfrastructureCosts(company, GSInfrastructure.INFRASTRUCTURE_CANAL);
		local profits = 0;
		foreach (value in vehicle_list) {
			profits += value;
		}
		local current_date = GSDate.GetCurrentDate();
		local current_year = GSDate.GetYear(current_date);
		local days_since_last_year = 365 + current_date - GSDate.GetDate(current_year, 1, 1);
		local efficiency = infrastructure_count > 0 ? (profits - maintenance_cost * days_since_last_year / 30 ) / infrastructure_count : 0;

		local station_list = GSStationList(GSStation.STATION_DOCK);
		local num_sts = station_list.Count();
		local visited_sts = 0;
		local loading_station_list = GSList();
		foreach (station, _ in station_list) {
			local station_vehicle_list = GSVehicleList_Station(station);
			station_vehicle_list.Valuate(GSVehicle.GetVehicleType);
			station_vehicle_list.KeepValue(GSVehicle.VT_WATER);
			if (!station_vehicle_list.IsEmpty()) {
				visited_sts++;
				foreach (vehicle, _ in station_vehicle_list) {
					local order_count = GSOrder.GetOrderCount(vehicle);
					for (local order = 0; order < order_count; order++) {
						if (GSOrder.IsGotoStationOrder(vehicle, order)) {
							if (GSStation.GetStationID(GSOrder.GetOrderDestination(vehicle, order)) == station) {
								local order_flags = GSOrder.GetOrderFlags(vehicle, order);
								if ((order_flags & GSOrder.OF_NO_LOAD) == 0 || (order_flags & GSOrder.OF_FULL_LOAD_ANY) != 0) {
									local tile_list_station_type = GSTileList_StationType(station, GSStation.STATION_DOCK);
									loading_station_list.AddItem(station, tile_list_station_type.Begin());
									break;
								}
							}
						}
					}
				}
			}
		}
		local visited_pct = num_sts > 0 ? (visited_sts * 100 / num_sts) : 0;

		local cargo_list = GSCargoList();
		local best_rated_station = -1;
		local highest_cargo_rating = 0;
		foreach (station, _ in loading_station_list) {
			foreach (cargo, _ in cargo_list) {
				if (GSStation.HasCargoRating(station, cargo)) {
					local cargo_rating = GSStation.GetCargoRating(station, cargo);
					if (cargo_rating > highest_cargo_rating) {
						best_rated_station = station;
						highest_cargo_rating = cargo_rating;
					}
				}
			}
		}

		rating = efficiency;
		score_text.params = [ visited_sts, num_sts, visited_pct, efficiency ];
		if (GSStation.IsValidStation(best_rated_station)) {
			local station_tile = loading_station_list.GetValue(best_rated_station);

			element_text.string = GetCanalInfrastructureEfficiency_ElementString();
			element_text.params = [ best_rated_station, highest_cargo_rating ];
			link_info = [ GSLeagueTable.LINK_TILE, station_tile ];
		}
	}

	return [ rating, score_text, element_text, link_info ];
}

function LeagueTables::GetCanalInfrastructureEfficiency_ScoreString()
{
	return GSText.STR_CANAL_INFRASTRUCTURE_EFFICIENCY_SCORE;
}

function LeagueTables::GetCanalInfrastructureEfficiency_TitleString()
{
	return GSText.STR_CANAL_INFRASTRUCTURE_EFFICIENCY_TITLE;
}

function LeagueTables::GetCanalInfrastructureEfficiency_HeaderString()
{
	return GSText.STR_CANAL_INFRASTRUCTURE_EFFICIENCY_HEADER;
}

function LeagueTables::GetCanalInfrastructureEfficiency_FooterString()
{
	return GSText.STR_CANAL_INFRASTRUCTURE_EFFICIENCY_FOOTER;
}

function LeagueTables::GetCanalInfrastructureEfficiency_ElementString()
{
	return GSText.STR_CANAL_INFRASTRUCTURE_EFFICIENCY_ELEMENT;
}
