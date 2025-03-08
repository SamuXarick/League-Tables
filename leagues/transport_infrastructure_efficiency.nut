function LeagueTables::GetTransportInfrastructureEfficiency_Stats(company)
{
	local rating = 0;
	local score_text = SetText(GetTransportInfrastructureEfficiency_ScoreString(), [ 0, 0, 0, 0 ]);
	local element_text = SetText(GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_NONE);
	local link_info = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);

		local infrastructure_count = GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_RAIL);
		infrastructure_count += GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_SIGNALS);
		infrastructure_count += GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_ROAD);
		infrastructure_count += GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_CANAL);
		infrastructure_count += GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_AIRPORT);
		infrastructure_count += GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_STATION);

		local station_list = GSStationList(GSStation.STATION_ANY);
		local num_sts = station_list.Count();
		local visited_sts = 0;
		local loading_station_list = GSList();
		foreach (station, _ in station_list) {
			if (GSStation.HasStationType(station, GSStation.STATION_AIRPORT)) {
				local airport_type = GSAirport.GetAirportType(GSBaseStation.GetLocation(station));
				infrastructure_count += max(1, GSAirport.GetAirportWidth(airport_type) * GSAirport.GetAirportHeight(airport_type));
			}
			local station_vehicle_list = GSVehicleList_Station(station);
			if (!station_vehicle_list.IsEmpty()) {
				visited_sts++;
				foreach (vehicle, _ in station_vehicle_list) {
					local order_count = GSOrder.GetOrderCount(vehicle);
					for (local order = 0; order < order_count; order++) {
						if (GSOrder.IsGotoStationOrder(vehicle, order)) {
							if (GSStation.GetStationID(GSOrder.GetOrderDestination(vehicle, order)) == station) {
								local order_flags = GSOrder.GetOrderFlags(vehicle, order);
								if ((order_flags & GSOrder.OF_NO_LOAD) == 0 || (order_flags & GSOrder.OF_FULL_LOAD_ANY) != 0) {
									loading_station_list.AddItem(station, GSBaseStation.GetLocation(station));
								}
							}
						}
					}
				}
			}
		}
		local visited_pct = num_sts > 0 ? (visited_sts * 100 / num_sts) : 0;

		local vehicle_list = GSVehicleList();
		local get_profits = function(vehicle_id) { return GSVehicle.GetProfitLastYear(vehicle_id) + GSVehicle.GetProfitThisYear(vehicle_id); };
		vehicle_list.Valuate(get_profits);

		local maintenance_cost = GSInfrastructure.GetMonthlyInfrastructureCosts(company, GSInfrastructure.INFRASTRUCTURE_RAIL);
		maintenance_cost += GSInfrastructure.GetMonthlyInfrastructureCosts(company, GSInfrastructure.INFRASTRUCTURE_SIGNALS);
		maintenance_cost += GSInfrastructure.GetMonthlyInfrastructureCosts(company, GSInfrastructure.INFRASTRUCTURE_ROAD);
		maintenance_cost += GSInfrastructure.GetMonthlyInfrastructureCosts(company, GSInfrastructure.INFRASTRUCTURE_CANAL);
		maintenance_cost += GSInfrastructure.GetMonthlyInfrastructureCosts(company, GSInfrastructure.INFRASTRUCTURE_AIRPORT);
		maintenance_cost += GSInfrastructure.GetMonthlyInfrastructureCosts(company, GSInfrastructure.INFRASTRUCTURE_STATION);

		local profits = 0;
		foreach (value in vehicle_list) {
			profits += value;
		}
		local current_date = GSDate.GetCurrentDate();
		local current_year = GSDate.GetYear(current_date);
		local days_since_last_year = 365 + current_date - GSDate.GetDate(current_year, 1, 1);
		local efficiency = infrastructure_count > 0 ? (profits - maintenance_cost * days_since_last_year / 30 ) / infrastructure_count : 0;

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

			local station_rail = GSStation.HasStationType(best_rated_station, GSStation.STATION_TRAIN) ? GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_TRAIN : GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_NONE;
			local station_truck = GSStation.HasStationType(best_rated_station, GSStation.STATION_TRUCK_STOP) ? GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_LORRY : GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_NONE;
			local station_bus = GSStation.HasStationType(best_rated_station, GSStation.STATION_BUS_STOP) ? GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_BUS : GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_NONE;
			local station_dock = GSStation.HasStationType(best_rated_station, GSStation.STATION_DOCK) ? GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_SHIP : GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_NONE;
			local station_airport = GSStation.HasStationType(best_rated_station, GSStation.STATION_AIRPORT) ? GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_PLANE : GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_NONE;

			element_text.string = GetTransportInfrastructureEfficiency_ElementString();
			element_text.params = [ SetText(station_rail), SetText(station_truck), SetText(station_bus), SetText(station_dock), SetText(station_airport), best_rated_station, highest_cargo_rating ];
			link_info = [ GSLeagueTable.LINK_TILE, station_tile ];
		}
	}

	return [ rating, score_text, element_text, link_info ];
}

function LeagueTables::GetTransportInfrastructureEfficiency_ScoreString()
{
	return GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_SCORE;
}

function LeagueTables::GetTransportInfrastructureEfficiency_TitleString()
{
	return GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_TITLE;
}

function LeagueTables::GetTransportInfrastructureEfficiency_HeaderString()
{
	return GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_HEADER;
}

function LeagueTables::GetTransportInfrastructureEfficiency_FooterString()
{
	return GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_FOOTER;
}

function LeagueTables::GetTransportInfrastructureEfficiency_ElementString()
{
	return GSText.STR_TRANSPORT_INFRASTRUCTURE_EFFICIENCY_ELEMENT;
}
