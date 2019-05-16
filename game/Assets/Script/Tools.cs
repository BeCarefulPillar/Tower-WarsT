using Newtonsoft.Json;

public static class Tools
{
    public static string Serialize(object o)
    {
        return JsonConvert.SerializeObject(o);
    }
    public static T Deserialize<T>(string s)
    {
        return JsonConvert.DeserializeObject<T>(s);
    }
}