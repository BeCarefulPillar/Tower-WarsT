using JumpCSV;

public static class Loc  {
    public static string Str(int id, params object[] args) {
        string val = "";
        if(id == 0) return val;
        val = LocalizationCsvData.text(id);
        if(args != null && args.Length != 0) {
            val = string.Format(val, args);
        }
        return val;
    }
}
