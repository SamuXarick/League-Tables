function LeagueTable::GetMostProfitableVehicle_Val(company)
{
	local veh_type_str = GSText.STR_MOST_PROFITABLE_VEHICLE_NONE;

	local rating = 0;
	local score = SetText(GetMostProfitableVehicle_ScoreString(), [ 0, 0, 0, 0 ]);
	local element = SetText(GetMostProfitableVehicle_ElementString(), [ SetText(veh_type_str), -1 ]);
	local link = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);
		local total_profits = GSList();
		local vehicle_list = GSVehicleList();
		if (vehicle_list.Count() != 0) {
			vehicle_list.Valuate(GSVehicle.GetProfitThisYear);
			total_profits.AddList(vehicle_list);

			vehicle_list.Valuate(GSVehicle.GetProfitLastYear);
			foreach (vehicle, value in vehicle_list) {
				total_profits.SetValue(vehicle, (total_profits.GetValue(vehicle) + value));
			}

			local vehicle = total_profits.Begin();
			local vehicle_location = GSVehicle.GetLocation(vehicle);
			
			switch (GSVehicle.GetVehicleType(vehicle)) {
				case GSVehicle.VT_RAIL:  veh_type_str = GSText.STR_MOST_PROFITABLE_VEHICLE_TRAIN; break;
				case GSVehicle.VT_AIR:   veh_type_str = GSText.STR_MOST_PROFITABLE_VEHICLE_PLANE; break;
				case GSVehicle.VT_WATER: veh_type_str = GSText.STR_MOST_PROFITABLE_VEHICLE_SHIP;  break;
				case GSVehicle.VT_ROAD: {
					local road_veh_type = GSRoad.GetRoadVehicleTypeForCargo(GSEngine.GetCargoType(GSVehicle.GetEngineType(vehicle)));
					veh_type_str = road_veh_type == GSRoad.ROADVEHTYPE_BUS ? GSText.STR_MOST_PROFITABLE_VEHICLE_BUS : GSText.STR_MOST_PROFITABLE_VEHICLE_LORRY;
					break;
				}
			}
			
			local average = 0;
			local best_value = 0x8000000000000000;
			local worst_value = 0x7FFFFFFFFFFFFFFF;
			foreach (_, value in total_profits) {
				average += value;
				if (value > best_value) best_value = value;
				if (value < worst_value) worst_value = value;
			}
			
			average = average / total_profits.Count();
			local ratio = 0;
			if (best_value >= 0 && average >= 0) {
				ratio = average * 100 / (best_value != 0 ? best_value : 1);
			}
			
			rating = total_profits.GetValue(vehicle);
			score.p = [ worst_value, average, best_value, ratio ];
			element.p = [ SetText(veh_type_str), vehicle ];
			link = [ GSLeagueTable.LINK_TILE, vehicle_location ];
		}
	}

	return [ rating, score, element, link ];
}

function LeagueTable::GetMostProfitableVehicle_ScoreString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_SCORE;
}

function LeagueTable::GetMostProfitableVehicle_TitleString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_TITLE;
}

function LeagueTable::GetMostProfitableVehicle_HeaderString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_HEADER;
}

function LeagueTable::GetMostProfitableVehicle_FooterString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_FOOTER;
}

function LeagueTable::GetMostProfitableVehicle_ElementString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_ELEMENT;
}
