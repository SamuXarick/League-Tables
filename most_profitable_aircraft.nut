function LeagueTable::GetMostProfitableAircraft_Val(company)
{
	local rating = 0;
	local score = SetText(GetMostProfitableAircraft_ScoreString(), [ 0, 0, 0, 0 ]);
	local element = SetText(GSText.STR_MOST_PROFITABLE_AIRCRAFT_NONE, [ -1 ]);
	local link = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);
		local total_profits = GSList();
		local vehicle_list = GSVehicleList();
		vehicle_list.Valuate(GSVehicle.GetVehicleType);
		vehicle_list.KeepValue(GSVehicle.VT_AIR);
		if (vehicle_list.Count() != 0) {
			vehicle_list.Valuate(GSVehicle.GetProfitThisYear);
			total_profits.AddList(vehicle_list);

			vehicle_list.Valuate(GSVehicle.GetProfitLastYear);
			foreach (vehicle, value in vehicle_list) {
				total_profits.SetValue(vehicle, (total_profits.GetValue(vehicle) + value));
			}

			local vehicle = total_profits.Begin();
			local vehicle_location = GSVehicle.GetLocation(vehicle);

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
			element = SetText(GetMostProfitableAircraft_ElementString(), [ vehicle ]);
			link = [ GSLeagueTable.LINK_TILE, vehicle_location ];
		}
	}

	return [ rating, score, element, link ];
}

function LeagueTable::GetMostProfitableAircraft_ScoreString()
{
	return GSText.STR_MOST_PROFITABLE_AIRCRAFT_SCORE;
}

function LeagueTable::GetMostProfitableAircraft_TitleString()
{
	return GSText.STR_MOST_PROFITABLE_AIRCRAFT_TITLE;
}

function LeagueTable::GetMostProfitableAircraft_HeaderString()
{
	return GSText.STR_MOST_PROFITABLE_AIRCRAFT_HEADER;
}

function LeagueTable::GetMostProfitableAircraft_FooterString()
{
	return GSText.STR_MOST_PROFITABLE_AIRCRAFT_FOOTER;
}

function LeagueTable::GetMostProfitableAircraft_ElementString()
{
	return GSText.STR_MOST_PROFITABLE_AIRCRAFT_ELEMENT;
}
