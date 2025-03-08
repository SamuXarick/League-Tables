function LeagueTables::GetCompanyValueTable_Stats(company)
{
	local rating = GSCompany.GetQuarterlyCompanyValue(company, GSCompany.CURRENT_QUARTER);
	local score_text = SetText(GetCompanyValueTable_ScoreString(), [ 0, 0, 0 ]);
	local element_text = SetText(GetCompanyValueTable_ElementString(), [ company, company ]);
	local link_info = [ GSLeagueTable.LINK_COMPANY, company ];

	if (GSCompany.ResolveCompanyID(company) != GSCompany.COMPANY_INVALID) {
		local last_quarter = GSCompany.GetQuarterlyCompanyValue(company, 1);
		local last_2_quarters = GSCompany.GetQuarterlyCompanyValue(company, 2);
		local last_3_quarters = GSCompany.GetQuarterlyCompanyValue(company, 3);
		local diff_to_last_quarter = rating - last_quarter;
		local quarter_over_quarter = (last_3_quarters - last_2_quarters) - (last_2_quarters - last_quarter);

		score_text.params = [ quarter_over_quarter, diff_to_last_quarter, rating ];
	}

	return [ rating, score_text, element_text, link_info ];
}

function LeagueTables::GetCompanyValueTable_ScoreString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_SCORE;
}

function LeagueTables::GetCompanyValueTable_TitleString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_TITLE;
}

function LeagueTables::GetCompanyValueTable_HeaderString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_HEADER;
}

function LeagueTables::GetCompanyValueTable_FooterString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_FOOTER;
}

function LeagueTables::GetCompanyValueTable_ElementString()
{
	return GSText.STR_COMPANY_VALUE_TABLE_ELEMENT;
}
