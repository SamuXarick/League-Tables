function LeagueTables::Save()
{
	return {
		tables = this.tables,
		async_mode = this.async_mode,
		update_mode = this.update_mode,
		timer = this.timer,
	};
}

function LeagueTables::Load(version, data)
{
	assert(data.rawin("tables") == (version >= 1));
	assert(data.rawin("async_mode") == (version >= 3));
	assert(data.rawin("update_mode") == (version >= 3));
	assert(data.rawin("timer") == (version >= 3));

	if (data.rawin("tables")) {
		foreach (i, table in data.tables) {
			assert(table.rawin("el") == (version >= 1 && version < 3));
			assert(table.rawin("element") == (version >= 3));

			if (table.rawin("el")) {
				table.rawset("element", table.rawget("el"));
				table.rawdelete("el");
				assert(!table.rawin("el"));
			}

			assert(table.rawin("val") == (version >= 1 && version < 3));
			assert(table.rawin("stats") == (version >= 3));

			if (table.rawin("val")) {
				table.rawset("stats", table.rawget("val"));
				table.rawdelete("val");
				assert(!table.rawin("val"));
			}

			assert(table.rawin("pct") == (version >= 1 && version < 3));
			assert(table.rawin("percentage") == (version >= 3));

			if (table.rawin("pct")) {
				table.rawset("percentage", table.rawget("pct"));
				table.rawdelete("pct");
				assert(!table.rawin("pct"));
			}

			foreach (stat in table.stats) {
				Load_RenameText(stat[1], version);
				Load_RenameText(stat[2], version);
			}

			this.tables[i] = clone table;
		}
	}

	if (data.rawin("async_mode")) this.async_mode = data.async_mode;
	if (data.rawin("update_mode")) this.update_mode = data.update_mode;
	if (data.rawin("timer")) this.timer = data.timer;
}

function LeagueTables::Load_RenameText(text, version)
{
	assert(typeof(text) == "table");
	assert(text.rawin("str") == (version >= 1 && version < 3));
	assert(text.rawin("string") == (version >= 3));

	if (text.rawin("str")) {
		text.rawset("string", text.rawget("str"));
		text.rawdelete("str");
		assert(!text.rawin("str"));
	}

	assert(text.rawin("p") == (version >= 1 && version < 3));
	assert(text.rawin("params") == (version >= 3));

	if (text.rawin("p")) {
		text.rawset("params", text.rawget("p"));
		text.rawdelete("p");
		assert(!text.rawin("p"));
	}

	foreach (param in text.params) {
		if (typeof(param) == "table") {
			Load_RenameText(param, version);
		}
	}
}
