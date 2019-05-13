
using System;
using System.Collections.Generic;
using UnityEngine;
using JumpCSV;
using System.Globalization;
using Logger;



#if UNITY_IOS && !UNITY_EDITOR
using System.Runtime.InteropServices;
public static class Locale {
    [DllImport ("__Internal")]
    private static extern string _getCountryCode ();
     
    public static string GetCountryCode () {
        return _getCountryCode();
    }
}
#endif

[Serializable]
public class Language {
	public enum Type {
		CN = 1,
		CNT= 2,
		EN = 3,
		KR = 4,
		None=255
	}
	public Type type;
}

public enum ECurrencySymbol {
	CNY,   // rmb
	TWD,   // taiwan dollar
	HKD,   // hongkong dollar
    USD,   // us. dollar
    MOP,   // macau pataca
    KRW,   // south korean won
}

public class LocalizationMgr : Singleton<LocalizationMgr> {
	// List<string> englishFonts = new List<string>() {
	// 	"Freeroad Light",
	// 	"Freeroad Regular",
	// 	"freewaygothic",
	// 	"HWYGCOND",
	// 	"HWYGNRRW",
	// 	"HWYGOTH",
	// 	"OldSansBlack",
	// };

	public static Dictionary<Language.Type, string> LanguageNameDic = new Dictionary<Language.Type, string>() {
		{Language.Type.CN,   "简体中文"},
		{Language.Type.CNT,  "繁體中文"},
		{Language.Type.EN,   "English"},
		{Language.Type.KR,   "한국어"},
	};

	public static Dictionary<Language.Type, string[]> OverrideFontsNameDic = new Dictionary<Language.Type, string[]>() {
		{Language.Type.CN,   new string[0]},
		{Language.Type.CNT,  new string[0]},
		{Language.Type.EN,   new string[0]},
		{Language.Type.KR,   new string[0]},
	};

// 	public static Dictionary<Language.Type, Dictionary<LocalLabel.EFontType, string>> DefaultFontMapper = new Dictionary<Language.Type, Dictionary<LocalLabel.EFontType, string>>() {
// 		{Language.Type.CN,   new Dictionary<LocalLabel.EFontType, string>(){
// 			{LocalLabel.EFontType.Title, "wenyue_young"},
// 			{LocalLabel.EFontType.Text,  "yuan-cuti"}
// 		}},		
// 		
// 		{Language.Type.CNT,  new Dictionary<LocalLabel.EFontType, string>(){
// 			{LocalLabel.EFontType.Title, "wenyue_young"},
// 			{LocalLabel.EFontType.Text,  "yuan-cuti"}
// 		}},
// 		
// 		{Language.Type.EN,   new Dictionary<LocalLabel.EFontType, string>(){
// 			{LocalLabel.EFontType.Title, "MontserratAlternates-ExtraBold.woff"},
// 			{LocalLabel.EFontType.Text,  "Montserrat-Medium"}
// 		}},
// 		
// 		{Language.Type.KR,   new Dictionary<LocalLabel.EFontType, string>(){
// 			{LocalLabel.EFontType.Title, "wenyue_young"},
// 			{LocalLabel.EFontType.Text,  "yuan-cuti"}
// 		}},
// 	};

 	public static Dictionary<Language.Type, List<string>> DefaultFontMapper = new Dictionary<Language.Type, List<string>>() {
		{Language.Type.CN,   new List<string>(){"wenyue_young", "yuan-cuti"} },
		{Language.Type.CNT,  new List<string>(){"wenyue_young", "yuan-cuti"} },
        {Language.Type.EN,  new List<string>(){"MontserratAlternates", "Montserrat-Medium"} },
        {Language.Type.KR,  new List<string>(){"wenyue_young", "yuan-cuti"} }
	};

	public static int MaxPlayerNameLen = 8;
	public static int MinPlayerNameLen = 3;

	public ECurrencySymbol currencySymbol;
	bool   isLoadCsv = false;

	private Language mLanguage = new Language();
	public Dictionary<string,Font> mFonts = new Dictionary<string,Font>();

	public Language.Type CurrentLanguage {
		get { return mLanguage.type; }
		set { mLanguage.type = value; }
	}

	public static string GetCountryCode() {
#if UNITY_ANDROID && !UNITY_EDITOR
		AndroidJavaClass  jc = new AndroidJavaClass("java.util.Locale");
        AndroidJavaObject jo = jc.CallStatic<AndroidJavaObject>("getDefault");
        string country     = jo.Call<string>("getCountry");
#elif UNITY_IOS && !UNITY_EDITOR
        string country     = Locale.GetCountryCode();
#else
        string country = "CN";
        if(!string.IsNullOrEmpty(CultureInfo.CurrentCulture.Name)) {
			RegionInfo re = new RegionInfo(CultureInfo.CurrentCulture.Name);
			country = re.TwoLetterISORegionName;
        }
#endif
        return country;
	}

	public void LoadCurrencySymbol() {
#if UNITY_ANDROID && !UNITY_EDITOR
		AndroidJavaClass  jc = new AndroidJavaClass("java.util.Locale");
        AndroidJavaObject jo = jc.CallStatic<AndroidJavaObject>("getDefault");
        string country     = jo.Call<string>("getCountry");
#elif UNITY_IOS && !UNITY_EDITOR
        string country     = Locale.GetCountryCode();
#else
        string country = "CN";
        if(!string.IsNullOrEmpty(CultureInfo.CurrentCulture.Name)) {
			RegionInfo re = new RegionInfo(CultureInfo.CurrentCulture.Name);
			country = re.TwoLetterISORegionName;
        }
#endif

	if(country == "CN") {
		currencySymbol = ECurrencySymbol.CNY;
    }
    else if(country == "HK") {
		currencySymbol = ECurrencySymbol.HKD;        	
    }
    else if(country == "TW") {
		currencySymbol = ECurrencySymbol.TWD;        	
    }
    else if(country == "MO") {
		currencySymbol = ECurrencySymbol.MOP;  	
    }
    else if(country == "KR") {
		currencySymbol = ECurrencySymbol.KRW;  	
    }
    else {
		currencySymbol = ECurrencySymbol.USD;
    }
}

	public Language.Type LoadSetting() {
        return Language.Type.CN;
		Language.Type lang = Language.Type.None;
		string v = PlayerPrefs.GetString("SETTING_LANG", "");
		if(!string.IsNullOrEmpty(v)) {
			try {
				lang = (Language.Type)Enum.Parse(typeof(Language.Type), v);
			} catch(ArgumentException) {
			}
		}
		return lang;
	}

	private Language.Type GetSystemSettings() {
		switch(Application.systemLanguage) {
		case SystemLanguage.ChineseSimplified:
			return Language.Type.CN;
		case SystemLanguage.ChineseTraditional:
			return Language.Type.CNT;
		// case SystemLanguage.Korean:
		// 	return Language.Type.KR;
		default:
			return Language.Type.EN;
		}
	}

	public void SetSetting(Language.Type lang) {
		if(CurrentLanguage != lang) {
			isLoadCsv = false;
		}
		CurrentLanguage = lang;
		SaveSetting();
	}

	public void SaveSetting() {
		PlayerPrefs.SetString("SETTING_LANG", CurrentLanguage.ToString());
		PlayerPrefs.Save();
	}

	public Font GetFont(string name) {
		if(mFonts.ContainsKey(name)) {
			return mFonts[name];
		}
		return null;
	}

	public void LoadFonts() {
		foreach(var fontName in DefaultFontMapper[CurrentLanguage]) {
			if(mFonts.ContainsKey(fontName) == false) {
				Font font = Resources.Load(string.Format("Fonts/{0}", fontName), typeof(Font)) as Font;
				if(font == null) {
					Log.Error("Can't load font {0}", fontName);
				} else {
					mFonts[fontName] = font;
				}				
			}			
		}
		foreach(var fontName in OverrideFontsNameDic[CurrentLanguage]) {
			if(mFonts.ContainsKey(fontName) == false) {
				Font font = Resources.Load(string.Format("Fonts/{0}", fontName), typeof(Font)) as Font;
				if(font == null) {
					Log.Error("Can't load font {0}", fontName);
				} else {
					mFonts[fontName] = font;
				}				
			}
		}
	}

	public void LoadCsv() {
#if UNITY_EDITOR && !HOT_FIX_TEST
		LocalizationCsvData.Read("Assets/Build/Localization/Localization_" + CurrentLanguage.ToString());
		//LocalizationPatchCsvData.Read(GameConfig.GetCurrentCsvTargetPath() + "LocalizationPatch");
#elif HOT_FIX_TEST
		LocalizationCsvData.Deserialize("LocalizationBin/Localization_" + CurrentLanguage.ToString(), true);		
		LocalizationPatchCsvData.Deserialize("CsvBin/LocalizationPatch", true);
#else
		LocalizationCsvData.Deserialize("LocalizationBin/Localization_" + CurrentLanguage.ToString(), true);
		LocalizationPatchCsvData.Deserialize("CsvBin/LocalizationPatch", true);
#endif
		// apply localization path for different ship
// 		for(int i = 0; i < LocalizationPatchCsvData.Data.Count; i++) {
// 			if(LocalizationPatchCsvData.Data[i].Source > 0 && LocalizationPatchCsvData.Data[i].Target > 0) {
// 				LocalizationCsvData.Data[LocalizationPatchCsvData.Data[i].Source] = new LocalizationRecord{_ID = LocalizationPatchCsvData.Data[i].Source, _VALUE = LocalizationPatchCsvData.Data[i].Source, text = LocalizationCsvData.Data[LocalizationPatchCsvData.Data[i].Target].text};
// 			}
// 		}
	}

	public void Init() {
		DontDestroyOnLoad(gameObject);
		CurrentLanguage = LoadSetting();
		if(CurrentLanguage == Language.Type.None) {
			SetSetting(GetSystemSettings());
		}
		if(isLoadCsv == false) {
			LoadCsv();
			isLoadCsv = true;
		}
		LoadCurrencySymbol();
		LoadFonts();
	}

// 	public int GetUSDPriceNum(int productId) {
// 		return PurchaseLookup.USD(productId);				
// 	}
// 
// 	public int GetRMBPriceNum(int productId) {
// 		return PurchaseLookup.CNY(productId);		
// 	}
// 
// 	public int GetPriceNum(int productId) {
// 		switch(currencySymbol) {
// 		case ECurrencySymbol.USD:
// 			return PurchaseLookup.USD(productId);
// 		case ECurrencySymbol.CNY:
// 			return PurchaseLookup.CNY(productId);
// 		case ECurrencySymbol.TWD:
// 			return PurchaseLookup.TWD(productId);
// 		case ECurrencySymbol.HKD:
// 			return PurchaseLookup.HKD(productId);
// 		case ECurrencySymbol.MOP:
// 			return PurchaseLookup.MOP(productId);
// 		case ECurrencySymbol.KRW:
// 			return PurchaseLookup.KRW(productId);		
// 		default:
// 			return PurchaseLookup.USD(productId);
// 		}
// 	}
// 
// 	public string GetPrice(int productId) {
// 		switch(currencySymbol) {
// 		case ECurrencySymbol.USD:
// 			return string.Format("${0:0.##}", PurchaseLookup.USD(productId)/100.0) ;
// 		case ECurrencySymbol.CNY:
// 			return string.Format("￥{0:0.##}", PurchaseLookup.CNY(productId)/100.0) ;
// 		case ECurrencySymbol.TWD:
// 			return string.Format("NT${0:0.##}", PurchaseLookup.TWD(productId)/100.0) ;
// 		case ECurrencySymbol.HKD:
// 			return string.Format("HK${0:0.##}", PurchaseLookup.HKD(productId)/100.0) ;
// 		case ECurrencySymbol.MOP:
// 			return string.Format("MOP${0:0.##}", PurchaseLookup.MOP(productId)/100.0) ;
// 		case ECurrencySymbol.KRW:
// 			return string.Format("₩{0:0.##}", PurchaseLookup.KRW(productId)/100.0) ;
// 		default:
// 			return string.Format("${0:0.##}", PurchaseLookup.USD(productId)/100.0);
// 		}		
// 	}
// 
// 	public string GetDisplayCurrencySymbolName() {
// 		switch(currencySymbol) {
// 		case ECurrencySymbol.USD:
// 			return "$";
// 		case ECurrencySymbol.CNY:
// 			return "￥";
// 		case ECurrencySymbol.TWD:
// 			return "NT$";
// 		case ECurrencySymbol.HKD:
// 			return "HK$";
// 		case ECurrencySymbol.MOP:
// 			return "MOP$";
// 		case ECurrencySymbol.KRW:
// 			return "₩";
// 		default:
// 			return "$";
// 		}		
// 	}
}
