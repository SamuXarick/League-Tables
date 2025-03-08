function LeagueTables::GetMostProfitableRoadVehicle_Stats(company)
{
	local veh_type_str = GSText.STR_MOST_PROFITABLE_ROADVEHICLE_NONE;

	local rating = 0;
	local score_text = SetText(GetMostProfitableRoadVehicle_ScoreString(), [ 0, 0, 0, 0 ]);
	local element_text = SetText(GetMostProfitableRoadVehicle_ElementString(), [ SetText(veh_type_str), -1 ]);
	local link_info = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);
		local vehicle_list = GSVehicleList();
		vehicle_list.Valuate(GSVehicle.GetVehicleType);
		vehicle_list.KeepValue(GSVehicle.VT_ROAD);
		if (!vehicle_list.IsEmpty()) {
			local get_profits = function(vehicle_id) { return GSVehicle.GetProfitLastYear(vehicle_id) + GSVehicle.GetProfitThisYear(vehicle_id); };
			vehicle_list.Valuate(get_profits);

			local vehicle = vehicle_list.Begin();
			local vehicle_location = GSVehicle.GetLocation(vehicle);

			local road_veh_type = GSRoad.GetRoadVehicleTypeForCargo(GSEngine.GetCargoType(GSVehicle.GetEngineType(vehicle)));
			veh_type_str = road_veh_type == GSRoad.ROADVEHTYPE_BUS ? GSText.STR_MOST_PROFITABLE_ROADVEHICLE_BUS : GSText.STR_MOST_PROFITABLE_ROADVEHICLE_LORRY;

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

function LeagueTables::GetMostProfitableRoadVehicle_ScoreString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_SCORE;
}

function LeagueTables::GetMostProfitableRoadVehicle_TitleString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_TITLE;
}

function LeagueTables::GetMostProfitableRoadVehicle_HeaderString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_HEADER;
}

function LeagueTables::GetMostProfitableRoadVehicle_FooterString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_FOOTER;
}

function LeagueTables::GetMostProfitableRoadVehicle_ElementString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_ELEMENT;
}
