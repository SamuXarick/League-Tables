function LeagueTables::GetMostProfitableTrain_Stats(company)
{
	local rating = 0;
	local score_text = SetText(GetMostProfitableTrain_ScoreString(), [ 0, 0, 0, 0 ]);
	local element_text = SetText(GSText.STR_MOST_PROFITABLE_TRAIN_NONE, [ -1 ]);
	local link_info = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local company_scope = GSCompanyMode(company);
		local vehicle_list = GSVehicleList();
		vehicle_list.Valuate(GSVehicle.GetVehicleType);
		vehicle_list.KeepValue(GSVehicle.VT_RAIL);
		if (!vehicle_list.IsEmpty()) {
			local get_profits = function(vehicle_id) { return GSVehicle.GetProfitLastYear(vehicle_id) + GSVehicle.GetProfitThisYear(vehicle_id); };
			vehicle_list.Valuate(get_profits);

			local vehicle = vehicle_list.Begin();
			local vehicle_location = GSVehicle.GetLocation(vehicle);

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
			element_text = SetText(GetMostProfitableTrain_ElementString(), [ vehicle ]);
			link_info = [ GSLeagueTable.LINK_TILE, vehicle_location ];
		}
	}

	return [ rating, score_text, element_text, link_info ];
}

function LeagueTables::GetMostProfitableTrain_ScoreString()
{
	return GSText.STR_MOST_PROFITABLE_TRAIN_SCORE;
}

function LeagueTables::GetMostProfitableTrain_TitleString()
{
	return GSText.STR_MOST_PROFITABLE_TRAIN_TITLE;
}

function LeagueTables::GetMostProfitableTrain_HeaderString()
{
	return GSText.STR_MOST_PROFITABLE_TRAIN_HEADER;
}

function LeagueTables::GetMostProfitableTrain_FooterString()
{
	return GSText.STR_MOST_PROFITABLE_TRAIN_FOOTER;
}

function LeagueTables::GetMostProfitableTrain_ElementString()
{
	return GSText.STR_MOST_PROFITABLE_TRAIN_ELEMENT;
}
