function LeagueTable::GetCompanyValueTable_Val(company)
{
	local rating = GSCompany.GetQuarterlyCompanyValue(company, GSCompany.CURRENT_QUARTER);
	local score = SetText(GetCompanyValueTable_ScoreString(), [ 0, 0, 0 ]);
	local element = SetText(GetCompanyValueTable_ElementString(), [ company, company ]);
	local link = [ GSLeagueTable.LINK_COMPANY, company ];
	
	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local last_quarter = GSCompany.GetQuarterlyCompanyValue(company, 1);
		local last_2_quarters = GSCompany.GetQuarterlyCompanyValue(company, 2);
		local last_3_quarters = GSCompany.GetQuarterlyCompanyValue(company, 3);
		local diff_to_last_quarter = rating - last_quarter;
		local quarter_over_quarter = (last_3_quarters - last_2_quarters) - (last_2_quarters - last_quarter);
		
		score.p = [ quarter_over_quarter, diff_to_last_quarter, rating ];
	}

	return [ rating, score, element, link ];
}

function LeagueTable::GetCompanyValueTable_ScoreString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_SCORE;
}

function LeagueTable::GetCompanyValueTable_TitleString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_TITLE;
}

function LeagueTable::GetCompanyValueTable_HeaderString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_HEADER;
}

function LeagueTable::GetCompanyValueTable_FooterString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_FOOTER;
}

function LeagueTable::GetCompanyValueTable_ElementString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_ELEMENT;
}
