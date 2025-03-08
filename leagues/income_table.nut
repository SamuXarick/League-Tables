function LeagueTables::GetIncomeTable_Stats(company)
{
	local rating = 0;
	local score_text = SetText(GetIncomeTable_ScoreString(), [ 0, 0, 0 ]);
	local element_text = SetText(GSText.STR_INCOME_TABLE_NONE);
	local link_info = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local best_quarter = 0x8000000000000000;
		local worst_quarter = 0x7FFFFFFFFFFFFFFF;
		for (local quarter = GSCompany.CURRENT_QUARTER; quarter <= GSCompany.EARLIEST_QUARTER; quarter++) {
			local income = GSCompany.GetQuarterlyIncome(company, quarter);
			rating += income;
			if (income > best_quarter) best_quarter = income;
			if (income < worst_quarter) worst_quarter = income;
		}

		local company_scope = GSCompanyMode(company);

		local num_trains = GSGroup.GetNumVehicles(GSGroup.GROUP_ALL, GSVehicle.VT_RAIL);
		local num_roadvehs = GSGroup.GetNumVehicles(GSGroup.GROUP_ALL, GSVehicle.VT_ROAD);
		local num_ships = GSGroup.GetNumVehicles(GSGroup.GROUP_ALL, GSVehicle.VT_WATER);
		local num_aircraft = GSGroup.GetNumVehicles(GSGroup.GROUP_ALL, GSVehicle.VT_AIR);

		local num_train_stations = GSStationList(GSStation.STATION_TRAIN).Count();
		local num_roadveh_stations = GSStationList(GSStation.STATION_TRUCK_STOP | GSStation.STATION_BUS_STOP).Count();
		local num_ship_stations = GSStationList(GSStation.STATION_DOCK).Count();
		local num_aircraft_stations = GSStationList(GSStation.STATION_AIRPORT).Count();

		rating /= 1 + GSCompany.EARLIEST_QUARTER - GSCompany.CURRENT_QUARTER;
		score_text.params = [ worst_quarter, best_quarter, rating ];
		if (num_trains != 0 || num_roadvehs != 0 || num_ships != 0 || num_aircraft != 0 || num_train_stations != 0 || num_roadveh_stations != 0 || num_ship_stations != 0 || num_aircraft_stations != 0) {
			local train_text = (num_trains != 0 || num_train_stations != 0) ? SetText(GSText.STR_INCOME_TABLE_TRAIN, [num_trains, num_train_stations]) : SetText(GSText.STR_INCOME_TABLE_NONE_STRING_STRING, [ SetText(GSText.STR_INCOME_TABLE_NONE), SetText(GSText.STR_INCOME_TABLE_NONE) ]);
			local roadveh_text = (num_roadvehs != 0 || num_roadveh_stations != 0) ? SetText(GSText.STR_INCOME_TABLE_LORRY, [ num_roadvehs, num_roadveh_stations ]) : SetText(GSText.STR_INCOME_TABLE_NONE_STRING_STRING, [ SetText(GSText.STR_INCOME_TABLE_NONE), SetText(GSText.STR_INCOME_TABLE_NONE) ]);
			local ship_text = (num_ships != 0 || num_ship_stations != 0) ? SetText(GSText.STR_INCOME_TABLE_SHIP, [ num_ships, num_ship_stations ]) : SetText(GSText.STR_INCOME_TABLE_NONE_STRING_STRING, [ SetText(GSText.STR_INCOME_TABLE_NONE), SetText(GSText.STR_INCOME_TABLE_NONE) ]);
			local aircraft_text = (num_aircraft != 0 || num_aircraft_stations != 0) ? SetText(GSText.STR_INCOME_TABLE_PLANE, [ num_aircraft, num_aircraft_stations ]) : SetText(GSText.STR_INCOME_TABLE_NONE_STRING_STRING, [ SetText(GSText.STR_INCOME_TABLE_NONE), SetText(GSText.STR_INCOME_TABLE_NONE) ]);
			element_text = SetText(GetIncomeTable_ElementString(), [ train_text, roadveh_text, ship_text, aircraft_text ]);
		}
	}

	return [ rating, score_text, element_text, link_info ];
}

function LeagueTables::GetIncomeTable_ScoreString()
{
	return GSText.STR_INCOME_TABLE_SCORE;
}

function LeagueTables::GetIncomeTable_TitleString()
{
	return GSText.STR_INCOME_TABLE_TITLE;
}

function LeagueTables::GetIncomeTable_HeaderString()
{
	return GSText.STR_INCOME_TABLE_HEADER;
}

function LeagueTables::GetIncomeTable_FooterString()
{
	return GSText.STR_INCOME_TABLE_FOOTER;
}

function LeagueTables::GetIncomeTable_ElementString()
{
	return GSText.STR_INCOME_TABLE_ELEMENT;
}
