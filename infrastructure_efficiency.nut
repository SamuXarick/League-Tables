function LeagueTable::GetInfrastructureEfficiencyRail_Val(company)
{
	local rating = 0;
	local score = SetText(GetInfrastructureEfficiencyRail_ScoreString(), [ rating ]);
	local element = SetText(GetInfrastructureEfficiencyRail_ElementString(), [ company ]);
	
	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);
		
		local rail_infrastructure_count = GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_RAIL) + GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_SIGNALS);
		local road_infrastructure_count = GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_ROAD);
		local canal_infrastructure_count = GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_CANAL);
		local airport_infrastructure_count = GSInfrastructure.GetInfrastructurePieceCount(company, GSInfrastructure.INFRASTRUCTURE_AIRPORT);
		
		local vehicle_list = GSVehicleList();
		vehicle_list.Valuate(GSVehicle.GetVehicleType);
		local train_vehicle_list = GSList();
		local road_vehicle_list = GSList();
		local ship_vehicle_list = GSList();
		local aircraft_vehicle_list = GSList();
		train_vehicle_list.AddList(vehicle_list);
		road_vehicle_list.AddList(vehicle_list);
		ship_vehicle_list.AddList(vehicle_list);
		aircraft_vehicle_list.AddList(vehicle_list);
		train_vehicle_list.KeepValue(GSVehicle.VT_RAIL);
		road_vehicle_list.KeepValue(GSVehicle.VT_ROAD);
		ship_vehicle_list.KeepValue(GSVehicle.VT_WATER);
		aircraft_vehicle_list.KeepValue(GSVehicle.VT_AIR);
		train_vehicle_list.Valuate(GSVehicle.GetProfitLastYear);
		road_vehicle_list.Valuate(GSVehicle.GetProfitLastYear);
		ship_vehicle_list.Valuate(GSVehicle.GetProfitLastYear);
		aircraft_vehicle_list.Valuate(GSVehicle.GetProfitLastYear);
		
		local train_profits = 0;
		foreach (vehicle, value in train_vehicle_list) {
			train_profits += value + GSVehicle.GetProfitThisYear(vehicle);
		}
		
		local road_profits = 0;
		foreach (vehicle, value in road_vehicle_list) {
			road_profits += value + GSVehicle.GetProfitThisYear(vehicle);
		}
		
		local ship_profits = 0;
		foreach (vehicle, value in ship_vehicle_list) {
			ship_profits += value + GSVehicle.GetProfitThisYear(vehicle);
		}
		
		local aircraft_profits = 0;
		foreach (vehicle, value in aircraft_vehicle_list) {
			aircraft_profits += value + GSVehicle.GetProfitThisYear(vehicle);
		}
		
		local rail_efficiency = rail_infrastructure_count > 0 ? train_profits / rail_infrastructure_count : 0;
		local road_efficiency = road_infrastructure_count > 0 ? road_profits / road_infrastructure_count : 0;
		local canal_efficiency = canal_infrastructure_count > 0 ? ship_profits / canal_infrastructure_count : 0;
		local airport_efficiency = airport_infrastructure_count > 0 ? aircraft_profits / airport_infrastructure_count : 0;
		
		score.p = [ rail_efficiency, road_efficiency, canal_efficiency, airport_efficiency ];
		
		local any_station_list = GSStationList(GSStation.STATION_ANY);
		local num_rail_sts = 0;
		local num_road_sts = 0;
		local num_dock_sts = 0;
		local num_airport_sts = 0;
		local visited_rail_sts = 0;
		local visited_road_sts = 0;
		local visited_dock_sts = 0;
		local visited_airport_sts = 0;
		foreach (station, _ in any_station_list) {
			local station_vehicle_list = GSVehicleList_Station(station);
			station_vehicle_list.Valuate(GSVehicle.GetVehicleType);
			local count = station_vehicle_list.Count();
			if (GSStation.HasStationType(station, GSStation.STATION_TRAIN)) {
				num_rail_sts++;
				local old_count = count;
				station_vehicle_list.RemoveValue(GSVehicle.VT_RAIL);
				count = station_vehicle_list.Count();
				if ((old_count - count) > 0) visited_rail_sts++;
			}
			if (GSStation.HasStationType(station, GSStation.STATION_TRUCK_STOP) || GSStation.HasStationType(station, GSStation.STATION_BUS_STOP)) {
				num_road_sts++;
				local old_count = count;
				station_vehicle_list.RemoveValue(GSVehicle.VT_ROAD);
				count = station_vehicle_list.Count();
				if ((old_count - count) > 0) visited_road_sts++;
			}
			if (GSStation.HasStationType(station, GSStation.STATION_DOCK)) {
				num_dock_sts++;
				local old_count = count;
				station_vehicle_list.RemoveValue(GSVehicle.VT_WATER);
				count = station_vehicle_list.Count();
				if ((old_count - count) > 0) visited_dock_sts++;
			}
			if (GSStation.HasStationType(station, GSStation.STATION_AIRPORT)) {
				num_airport_sts++;
				local old_count = count;
				station_vehicle_list.RemoveValue(GSVehicle.VT_AIR);
				count = station_vehicle_list.Count();
				if ((old_count - count) > 0) visited_airport_sts++;
			}
		}
		local rail_pct = num_rail_sts > 0 ? (visited_rail_sts * 100 / num_rail_sts) : 0;
		local road_pct = num_road_sts > 0 ? (visited_road_sts * 100 / num_road_sts) : 0;
		local dock_pct = num_dock_sts > 0 ? (visited_dock_sts * 100 / num_dock_sts) : 0;
		local airport_pct = num_airport_sts > 0 ? (visited_airport_sts * 100 / num_airport_sts) : 0;

		element.p = [ visited_rail_sts, num_rail_sts, rail_pct, visited_road_sts, num_road_sts, road_pct, visited_dock_sts, num_dock_sts, dock_pct, visited_airport_sts, num_airport_sts, airport_pct ];
	}
	
	return [ rating, score, element ];
}

function LeagueTable::GetInfrastructureEfficiencyRail_ScoreString()
{
	return GSText.STR_INFRASTRUCTURE_EFFICIENCY_RAIL_SCORE;
}

function LeagueTable::GetInfrastructureEfficiencyRail_TitleString()
{
	return GSText.STR_INFRASTRUCTURE_EFFICIENCY_RAIL_TITLE;
}

function LeagueTable::GetInfrastructureEfficiencyRail_HeaderString()
{
	return GSText.STR_INFRASTRUCTURE_EFFICIENCY_RAIL_HEADER;
}

function LeagueTable::GetInfrastructureEfficiencyRail_FooterString()
{
	return GSText.STR_INFRASTRUCTURE_EFFICIENCY_RAIL_FOOTER;
}

function LeagueTable::GetInfrastructureEfficiencyRail_ElementString()
{
	return GSText.STR_INFRASTRUCTURE_EFFICIENCY_RAIL_ELEMENT;
}
