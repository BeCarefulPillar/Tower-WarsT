// ------------------------------------------------------------------------------
//  <autogenerated>
//      This code was generated by a tool.
//      Mono Runtime Version: 2.0.50727.1433
// 
//      Changes to this file may cause incorrect behavior and will be lost if 
//      the code is regenerated.
//  </autogenerated>
// ------------------------------------------------------------------------------

namespace JumpCSV {
    using System;
    using System.Collections.Generic;
    
    
    public class CsvManager {
        
        public static bool isInit = false;
        public static bool isAssetBundle = true;
        public static void Init(string prefix) {
            if(isInit) return;
            HeroCsvData.Read(prefix + "Hero");
            isInit = true;
        }
        
        public static System.Collections.IEnumerable ForeachInit() {
            HeroCsvData.Read("Hero");
            yield return null;
            isInit = true;
        }
        
        public static void Serialize(string prefix) {
            Init(prefix);
            HeroCsvData.Serialize("Assets/Resources/CsvBin/Hero.bytes");
        }
        
        public static void Deserialize() {
            if(isInit) return;
            HeroCsvData.Deserialize("CsvBin/Hero", isAssetBundle);
            isInit = true;
        }
        
        public static System.Collections.IEnumerable ForeachDeserialize() {
            HeroCsvData.Deserialize("CsvBin/Hero", isAssetBundle);
            yield return null;
            isInit = true;
        }
    }
    
    public class ERId {
        
        public const int None                 = 0;
        public const int HERO_SK              = 1;
        public const int HERO_XW              = 2;
        public const int LOC_SAY_HELLO_WORLD  = 1;
        public const int LOC_SUN_KANG         = 2;
        public const int LOC_SUN_KANG_DES     = 3;
        public const int LOC_XIANG_WEI        = 4;
        public const int LOC_XIANG_WEI_DES    = 5;
        
	}
}
