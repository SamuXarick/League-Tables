function LeagueTable::GetMostProfitableRoadVehicle_Val(company)
{
	local veh_type_str = GSText.STR_MOST_PROFITABLE_ROADVEHICLE_NONE;

	local rating = 0;
	local score = SetText(GetMostProfitableRoadVehicle_ScoreString(), [ 0, 0, 0, 0 ]);
	local element = SetText(GetMostProfitableRoadVehicle_ElementString(), [ SetText(veh_type_str), -1 ]);
	local link = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);
		local total_profits = GSList();
		local vehicle_list = GSVehicleList();
		vehicle_list.Valuate(GSVehicle.GetVehicleType);
		vehicle_list.KeepValue(GSVehicle.VT_ROAD);
		if (vehicle_list.Count() != 0) {
			vehicle_list.Valuate(GSVehicle.GetProfitThisYear);
			total_profits.AddList(vehicle_list);

			vehicle_list.Valuate(GSVehicle.GetProfitLastYear);
			foreach (vehicle, value in vehicle_list) {
				total_profits.SetValue(vehicle, (total_profits.GetValue(vehicle) + value));
			}

			local vehicle = total_profits.Begin();
			local vehicle_location = GSVehicle.GetLocation(vehicle);

			local road_veh_type = GSRoad.GetRoadVehicleTypeForCargo(GSEngine.GetCargoType(GSVehicle.GetEngineType(vehicle)));
			veh_type_str = road_veh_type == GSRoad.ROADVEHTYPE_BUS ? GSText.STR_MOST_PROFITABLE_ROADVEHICLE_BUS : GSText.STR_MOST_PROFITABLE_ROADVEHICLE_LORRY;

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

function LeagueTable::GetMostProfitableRoadVehicle_ScoreString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_SCORE;
}

function LeagueTable::GetMostProfitableRoadVehicle_TitleString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_TITLE;
}

function LeagueTable::GetMostProfitableRoadVehicle_HeaderString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_HEADER;
}

function LeagueTable::GetMostProfitableRoadVehicle_FooterString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_FOOTER;
}

function LeagueTable::GetMostProfitableRoadVehicle_ElementString()
{
	return GSText.STR_MOST_PROFITABLE_ROADVEHICLE_ELEMENT;
}
