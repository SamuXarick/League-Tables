function LeagueTables::GetMostProfitableVehicle_Stats(company)
{
	local veh_type_str = GSText.STR_MOST_PROFITABLE_VEHICLE_NONE;

	local rating = 0;
	local score_text = SetText(GetMostProfitableVehicle_ScoreString(), [ 0, 0, 0, 0 ]);
	local element_text = SetText(GetMostProfitableVehicle_ElementString(), [ SetText(veh_type_str), -1 ]);
	local link_info = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);
		local vehicle_list = GSVehicleList();
		if (!vehicle_list.IsEmpty()) {
			local get_profits = function(vehicle_id) { return GSVehicle.GetProfitLastYear(vehicle_id) + GSVehicle.GetProfitThisYear(vehicle_id); };
			vehicle_list.Valuate(get_profits);

			local vehicle = vehicle_list.Begin();
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
			foreach (value in vehicle_list) {
				average += value;
				if (value > best_value) best_value = value;
				if (value < worst_value) worst_value = value;
			}

			average /= vehicle_list.Count();
			local ratio = 0;
			if (best_value >= 0 && average >= 0) {
				ratio = average * 100 / (best_value != 0 ? best_value : 1);
			}

			rating = vehicle_list.GetValue(vehicle);
			score_text.params = [ worst_value, average, best_value, ratio ];
			element_text.params = [ SetText(veh_type_str), vehicle ];
			link_info = [ GSLeagueTable.LINK_TILE, vehicle_location ];
		}
	}

	return [ rating, score_text, element_text, link_info ];
}

function LeagueTables::GetMostProfitableVehicle_ScoreString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_SCORE;
}

function LeagueTables::GetMostProfitableVehicle_TitleString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_TITLE;
}

function LeagueTables::GetMostProfitableVehicle_HeaderString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_HEADER;
}

function LeagueTables::GetMostProfitableVehicle_FooterString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_FOOTER;
}

function LeagueTables::GetMostProfitableVehicle_ElementString()
{
	return GSText.STR_MOST_PROFITABLE_VEHICLE_ELEMENT;
}
