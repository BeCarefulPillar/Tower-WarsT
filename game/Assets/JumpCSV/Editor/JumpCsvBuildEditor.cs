using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections.Generic;
using System.Threading;

namespace JumpCSV {

public class JumpCsvBuildEditor : EditorWindow {
    [MenuItem ("JumpCSV/Build...")]
    static public void OpenWindow() {
        EditorWindow.GetWindow (typeof(JumpCsvBuildEditor));
    }

    public void OnEnable() {
        JumpCsvConfig.UpdateValue();
    }

    public void OnGUI() {
        DrawWidget(GameConfig.EShipChannel.TEST);
        GUILayout.Space(15);
        //DrawWidget(GameConfig.EShipChannel.CHINESE_ANDROID);
        GUILayout.Space(15);
        //DrawWidget(GameConfig.EShipChannel.GRAVITY);
        GUILayout.Space(15);
        //DrawWidget(GameConfig.EShipChannel.CHINESE_OFFICAL);
    }

    void Update() {
        if(needRebuildBin == true && EditorApplication.isCompiling == false) {
            BakeCsv(lastBuildShipchannel, true);
            needRebuildBin = false;
        }
        if(needRebuildBin == true && EditorApplication.isCompiling == false && (DateTime.Now - lastBuildCsvTime).TotalSeconds > 3f) {
            needRebuildBin = false;
        }
    }
    bool needRebuildBin = false;
    DateTime lastBuildCsvTime;
    GameConfig.EShipChannel lastBuildShipchannel = GameConfig.EShipChannel.TEST;
    void DrawWidget(GameConfig.EShipChannel shipchannel) {
        string title = "";
        if(shipchannel == GameConfig.EShipChannel.TEST) {
            title = "测试开发";
        }
//         else if(shipchannel == GameConfig.EShipChannel.CHINESE_ANDROID) {
//             title = "椰岛";
//         }
//         else if(shipchannel == GameConfig.EShipChannel.CHINESE_OFFICAL) {
//             title = "SuperNova";
//         }
//         else if(shipchannel == GameConfig.EShipChannel.GRAVITY) {
//             title = "韩国重力";
//         }
        else {
            throw new Exception("can not find shipment " + shipchannel.ToString());
        }

        GUILayout.BeginHorizontal();
        GUILayout.Label(title,  GUILayout.Width(100));

        if(GUILayout.Button("Build Csv",  GUILayout.Width(200))) {
            try {
                BuildCsv(shipchannel, true);
            }
            catch (Exception e) {
                throw e;
            }
        }

//         if(GUILayout.Button("Csv Bake",  GUILayout.Width(200))) {
//             needRebuildBin = true;
//             lastBuildShipchannel = shipchannel;
//             try {
//                 BuildCsv(shipchannel);
//                 lastBuildCsvTime = DateTime.Now;
//             }
//             catch (Exception e) {
//                 needRebuildBin = false;
//                 throw e;
//             }
//         }
// 
//         if(GUILayout.Button("Build Json",  GUILayout.Width(200))) {
//             BuildJson(shipchannel);
//         }
//         if(GUILayout.Button("Build Map Overview",  GUILayout.Width(200))) {
//             BuildLevelsOverviewJson(shipchannel);
//         }
//         if(GUILayout.Button("Build Localization", GUILayout.Width(200))) {
//             try {
//                 EditorUtility.DisplayProgressBar("Building Csv", "正在生成csv代码", 0.5f);
//                 BuildLocalization();
//             }
//             catch(Exception e) {
//                 EditorUtility.DisplayDialog("错误", "生成localization失败，请查看控制台错误log", "Ok");
//                 Debug.Log(e.ToString());
//             }
//             finally {
//                 EditorUtility.DisplayDialog("成功", "生成localization成功。", "Ok");
//                 EditorUtility.ClearProgressBar();
//             }
// 
//         }
        GUILayout.EndHorizontal();
    }

    static public void BuildCsv(GameConfig.EShipChannel shipchannel, bool popupResult = false) {
        try {
            EditorUtility.DisplayProgressBar("Build Csv", "正在生成csv代码", 0.5f);
            var sw = System.Diagnostics.Stopwatch.StartNew();
            BuildLocalization();
            JumpCsvCodeGenerator.CreateAllCsvClassSourceFiles(GameConfig.GetCsvTargetPath(shipchannel), "Assets/Build/CSV/Common/");
            Debug.Log("Build Csv Complete: " + sw.Elapsed.TotalMilliseconds.ToString() + "ms");
        }
        catch (Exception e) {
            if(popupResult) {
                EditorUtility.DisplayDialog("错误", "生成csv代码失败，请查看控制台错误log", "Ok");
            }
            throw e;
        } finally {
            EditorUtility.ClearProgressBar();
            if(popupResult) {
                EditorUtility.DisplayDialog("成功", "生成csv代码成功。", "Ok");
            }
        }

    }

    static void BuildLocalization() {
        string mapLevelFolder = "Assets/Build/Localization";
        if(!Directory.Exists(mapLevelFolder)) {
            Directory.CreateDirectory(mapLevelFolder);
        }
        CsvReader.DOUBLEQUOTE = false;
        var csvReader = new CsvReader();
        csvReader.Read("Assets/Build/Localization/Localization.csv");
        CsvReader.DOUBLEQUOTE = true;
        int idIndex = -1;
        int valueIndex = -1;
        List<int> langList = new List<int>();
        List<string> langStr = new List<string>();

        for(int i = 0; i < csvReader.Width; i++) {
            if(csvReader.ReadCell(0, i).IndexOf ("_ID") >= 0) {
                idIndex = i;
            }
            else if(csvReader.ReadCell(0, i).IndexOf ("_VALUE") >= 0) {
                valueIndex = i;
            }
            else if(csvReader.ReadCell(0, i).IndexOf ("Comment") < 0) {
                langList.Add(i);
                langStr.Add(csvReader.ReadCell(0, i).Remove(csvReader.ReadCell(0, i).IndexOf (":")));
            }
        }

        for(int i = 0; i < langList.Count; i++) {
            using(StreamWriter sr = new StreamWriter(mapLevelFolder + "/Localization_" + langStr[i] + ".csv", false)) {
                string valueString = (valueIndex != -1)?",_VALUE":"";
                sr.WriteLine(csvReader.ReadCell(0, idIndex) + valueString + "," + "text:string");
                for(int j = 1; j < csvReader.Height; j++) {
                    string id   = csvReader.ReadCell(j, idIndex);
                    string val  = (valueIndex != -1)?csvReader.ReadCell(j, valueIndex):(j.ToString());
                    //string val  = csvReader.ReadCell(j, valueIndex);
                    string text = csvReader.ReadCell(j, langList[i]);
                    if( text.IndexOf(",")  > 0 ||
                        text.IndexOf("\"") > 0 ||
                        text.IndexOf("\n") > 0 ||
                        text.IndexOf("\r") > 0 ||
                        (text.Length >= 3 && text[0] == '"' && text[1] == '"' && text[2] != '"' )) {
                        text = "\"" + text + "\"";
                    }
                    string finalVal = (valueIndex != -1)?("," + val):"";
                    sr.WriteLine(id + finalVal + "," + text);
                }
            }
        }
        
        AssetDatabase.Refresh();
        // create localizationcsvdata.cs
        CsvSpreadSheet localizationSheet = new CsvSpreadSheet("Assets/Build/Localization/Localization_CN", true);
        localizationSheet.CsvFileName = "Assets/Build/Localization/Localization";
        var tmpFile = JumpCsvCodeGenerator.CreateCsvDataClassSourceFile2(localizationSheet);
        FileUtil.ReplaceFile(tmpFile, JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvEditorHelper.PathCombine(JumpCsvConfig.CsvSourceCodeFileDirectory, Path.GetFileName(tmpFile))));
        AssetDatabase.Refresh();



//         csvReader = new CsvReader();
//         csvReader.Read("Assets/Build/Localization/RandomName.csv");
//         idIndex = -1;
//         valueIndex = -1;
//         int maleSurname = -1;
//         int maleName = -1;
//         int femaleSurname = -1;
//         int femaleName = -1;
// 
//         for(int i = 0; i < csvReader.Width; i++) {
//             if(csvReader.ReadCell(0, i).IndexOf ("_ID") >= 0) {
//                 idIndex = i;
//             }
//             else if(csvReader.ReadCell(0, i).IndexOf ("_VALUE") >= 0) {
//                 valueIndex = i;
//             }
//             else if(csvReader.ReadCell(0, i).IndexOf ("MaleSurname") >=0 ) {
//                 maleSurname = i;
//             }
//             else if(csvReader.ReadCell(0, i).IndexOf ("MaleName") >=0 ) {
//                 maleName = i;
//             }
//             else if(csvReader.ReadCell(0, i).IndexOf ("FemaleSurname") >=0 ) {
//                 femaleSurname = i;
//             }
//             else if(csvReader.ReadCell(0, i).IndexOf ("FemaleName") >=0 ) {
//                 femaleName = i;
//             }
//         }
// 
//         int currentValue = 1;
//         int currentIndex = 0;
//         int currentHeight = 1;
//         for(int i = 0; i < langStr.Count; i++) {
//             using(StreamWriter sr = new StreamWriter(mapLevelFolder + "/RandomName_" + langStr[i] + ".csv", false)) {
//                 sr.WriteLine("_INDEX,MaleSurname:string[],MaleName:string[],FemaleSurname:string[],FemaleName:string[]");
//                 for(int j = currentHeight; j < csvReader.Height; j++, currentIndex++) {
//                     string val = csvReader.ReadCell(j, valueIndex);
//                     if(!string.IsNullOrEmpty(val) && Int32.Parse(val) != currentValue) {
//                         currentValue = Int32.Parse(val);
//                         currentIndex = 0;
//                         currentHeight = j;
//                         break;
//                     }
//                     if(currentIndex == 0) {
//                         sr.WriteLine(currentIndex.ToString() + "," + csvReader.ReadCell(j, maleSurname) + "," + csvReader.ReadCell(j, maleName) + "," + csvReader.ReadCell(j, femaleSurname) + "," + csvReader.ReadCell(j, femaleName));
//                     }
//                     else {
//                         sr.WriteLine("," + csvReader.ReadCell(j, maleSurname) + "," + csvReader.ReadCell(j, maleName) + "," + csvReader.ReadCell(j, femaleSurname) + "," + csvReader.ReadCell(j, femaleName));
//                     }
//                 }
//             }
//         }
//         AssetDatabase.Refresh();
//         // create localizationcsvdata.cs
//         localizationSheet = new CsvSpreadSheet("Assets/Build/Localization/RandomName_CN", true);
//         localizationSheet.CsvFileName = "Assets/Build/Localization/RandomName";
//         tmpFile = JumpCsvCodeGenerator.CreateCsvDataClassSourceFile(localizationSheet);
//         FileUtil.ReplaceFile(tmpFile, JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvEditorHelper.PathCombine(JumpCsvConfig.CsvSourceCodeFileDirectory, Path.GetFileName(tmpFile))));
//         AssetDatabase.Refresh();

    }

    static void BakeCsv(GameConfig.EShipChannel shipchannel, bool popupResult = false) {
        var sw = System.Diagnostics.Stopwatch.StartNew();
        BakeLocalizationCsv();
        CsvManager.isInit = false;
        string directory = JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvBinDataDirectory);
        if(!Directory.Exists(directory)) {
            Directory.CreateDirectory(directory);
        }
        CsvManager.Serialize(GameConfig.GetCsvTargetPath(shipchannel));
        AssetDatabase.Refresh();
        if(popupResult) {
            EditorUtility.DisplayDialog("成功", "生成csv文件成功。", "Ok");
        }
        Debug.Log("Bake Csv Complete: " + sw.Elapsed.TotalMilliseconds.ToString() + "ms");
    }

    static void BakeLocalizationCsv() {
        var csvReader = new CsvReader();
        csvReader.Read("Assets/Build/Localization/Localization.csv");
        List<string> langStr = new List<string>();

        string localizationBinFolder = "Assets/Resources/LocalizationBin";
        if(!Directory.Exists(localizationBinFolder)) {
            Directory.CreateDirectory(localizationBinFolder);
        }

        for(int i = 0; i < csvReader.Width; i++) {
            if(csvReader.ReadCell(0, i).IndexOf ("_ID") >= 0) {
            }
            else if(csvReader.ReadCell(0, i).IndexOf ("_VALUE") >= 0) {
            }
            else if(csvReader.ReadCell(0, i).IndexOf ("Comment") < 0) {
                langStr.Add(csvReader.ReadCell(0, i).Remove(csvReader.ReadCell(0, i).IndexOf (":")));
            }
        }

        for(int i = 0; i < langStr.Count; i++) {
            LocalizationCsvData.Read("Assets/Build/Localization/Localization_" + langStr[i]);
            LocalizationCsvData.Serialize(localizationBinFolder + "/Localization_" + langStr[i] + ".bytes");
        }
        AssetDatabase.Refresh();


//         for(int i = 0; i < langStr.Count; i++) {
//             RandomNameCsvData.Read("Assets/Build/Localization/RandomName_" + langStr[i]);
//             RandomNameCsvData.Serialize(localizationBinFolder + "/RandomName_" + langStr[i] + ".bytes");
//         }
        AssetDatabase.Refresh();
    }
 
     void BuildJson(GameConfig.EShipChannel shipchannel) {
//         JumpCSV.CsvManager.isInit = false;
//         LocalizationCsvData.Read("Assets/Build/Localization/Localization_CN");
//         JumpCSV.CsvManager.Init(GameConfig.GetCsvTargetPath(shipchannel));
//         Csv2Json("ArenaRankRewardCsvData",              ArenaRankRewardCsvData.Data,            ArenaRankRewardCsvData.RecordIdValue);
//         Csv2Json("ArenaRobotNameBaseCsvData",           ArenaRobotNameBaseCsvData.Data,         ArenaRobotNameBaseCsvData.RecordIdValue);
//         Csv2Json("ArmyTypeSkillTreeCsvData",            ArmyTypeSkillTreeCsvData.Data,          ArmyTypeSkillTreeCsvData.RecordIdValue);
//         Csv2Json("BadgeUpgradeCsvData",                 BadgeUpgradeCsvData.Data,               null);
//         Csv2Json("BanquetCsvData",                      BanquetCsvData.Data,                    BanquetCsvData.RecordIdValue);
//         Csv2Json("BuyCsvData",                          BuyCsvData.Data,                        BuyCsvData.RecordIdValue);
//         Csv2Json("BuyGoldCsvData",                      BuyGoldCsvData.Data,                    null);
//         Csv2Json("BuyGoldLevelCsvData",                 BuyGoldLevelCsvData.Data,               null);
//         Csv2Json("BuffNumberCsvData",                   BuffNumberCsvData.Data,                 null);
//         Csv2Json("CharacterTypeCsvData",                CharacterTypeCsvData.Data,              CharacterTypeCsvData.RecordIdValue);
//         Csv2Json("CorpsBattleCsvData",                  CorpsBattleCsvData.Data,                CorpsBattleCsvData.RecordIdValue);
//         Csv2Json("CorpsBreakCsvData",                   CorpsBreakCsvData.Data,                 CorpsBreakCsvData.RecordIdValue);
//         Csv2Json("CorpsStarCsvData",                    CorpsStarCsvData.Data,                  null);
//         Csv2Json("CrusadeChallengeCsvData",             CrusadeChallengeCsvData.Data,           null);
//         Csv2Json("CrusadeChallengeBattleSoulCsvData",   CrusadeChallengeBattleSoulCsvData.Data, null);
//         Csv2Json("CrusadeChallengeGoldCsvData",         CrusadeChallengeGoldCsvData.Data,       null);
//         Csv2Json("DailyRewardsCsvData",                 DailyRewardsCsvData.Data,               null);
//         Csv2Json("DailyQuestCsvData",                   DailyQuestCsvData.Data,                 DailyQuestCsvData.RecordIdValue);
//         Csv2Json("DailyQuestRewardCsvData",             DailyQuestRewardCsvData.Data,           DailyQuestRewardCsvData.RecordIdValue);
//         Csv2Json("DetailUnitCsvData",                   DetailUnitCsvData.Data,                 DetailUnitCsvData.RecordIdValue);
//         Csv2Json("DialogCsvData",                       DialogCsvData.Data,                     DialogCsvData.RecordIdValue);
//         Csv2Json("DropGroupCsvData",                    DropGroupCsvData.Data,                  DropGroupCsvData.RecordIdValue);
//         Csv2Json("EquipmentUpgradeCsvData",             EquipmentUpgradeCsvData.Data,           null);
//         Csv2Json("EquipmentEvolveCsvData",              EquipmentEvolveCsvData.Data,            null);
//         Csv2Json("EquipmentCsvData",                    EquipmentCsvData.Data,                  EquipmentCsvData.RecordIdValue);
//         Csv2Json("ExpCsvData",                          ExpCsvData.Data,                        null);
//         Csv2Json("FeatureCsvData",                      FeatureCsvData.Data,                    FeatureCsvData.RecordIdValue);
//         Csv2Json("FightPowerCsvData",                   FightPowerCsvData.Data,                 FightPowerCsvData.RecordIdValue);
//         Csv2Json("GiftPackagesCsvData",                 GiftPackagesCsvData.Data,               GiftPackagesCsvData.RecordIdValue);
//         Csv2Json("GoldMineCsvData",                     GoldMineCsvData.Data,                   GoldMineCsvData.RecordIdValue);
//         Csv2Json("GuildAthleticCsvData",                GuildAthleticCsvData.Data,              null);
//         Csv2Json("GuildBehaviorChestCsvData",           GuildBehaviorChestCsvData.Data,         null);
//         Csv2Json("GuildContributionAwardCsvData",       GuildContributionAwardCsvData.Data,     GuildContributionAwardCsvData.RecordIdValue);
//         Csv2Json("HeroCsvData",                         HeroCsvData.Data,                       HeroCsvData.RecordIdValue);
//         Csv2Json("HeroEvolveCsvData",                   HeroEvolveCsvData.Data,                 HeroEvolveCsvData.RecordIdValue);
//         Csv2Json("ItemCsvData",                         ItemCsvData.Data,                       ItemCsvData.RecordIdValue);
//         Csv2Json("ItemPackageCsvData",                  ItemPackageCsvData.Data,                ItemPackageCsvData.RecordIdValue);
//         Csv2Json("LevelRewardsCsvData",                 LevelRewardsCsvData.Data,               null);
//         Csv2Json("LocalizationServerCsvData",           LocalizationServerCsvData.Data,         LocalizationServerCsvData.RecordIdValue);
//         Csv2Json("LotteryCsvData",                      LotteryCsvData.Data,                    LotteryCsvData.RecordIdValue);
//         Csv2Json("MapLevelCsvData",                     MapLevelCsvData.Data,                   MapLevelCsvData.RecordIdValue);
//         Csv2Json("MapLevelChestCsvData",                MapLevelChestCsvData.Data,              MapLevelChestCsvData.RecordIdValue);
//         Csv2Json("MainQuestCsvData",                    MainQuestCsvData.Data,                  MainQuestCsvData.RecordIdValue);
//         Csv2Json("PetCsvData",                          PetCsvData.Data,                        PetCsvData.RecordIdValue);
//         Csv2Json("PurchaseCsvData",                     PurchaseCsvData.Data,                   null);
//         Csv2Json("PlayerInfoCsvData",                   PlayerInfoCsvData.Data,                 null);
//         Csv2Json("PlayModeAttackOnCsvData",             PlayModeAttackOnCsvData.Data,           PlayModeAttackOnCsvData.RecordIdValue);
//         Csv2Json("RunePriceCsvData",                    RunePriceCsvData.Data,                  RunePriceCsvData.RecordIdValue);
//         Csv2Json("ShopCsvData",                         ShopCsvData.Data,                       ShopCsvData.RecordIdValue);
//         Csv2Json("ShopDropGroupCsvData",                ShopDropGroupCsvData.Data,              ShopDropGroupCsvData.RecordIdValue);
//         Csv2Json("SevenDaysRewardsCsvData",             SevenDaysRewardsCsvData.Data,           null);
//         Csv2Json("SparCsvData",                         SparCsvData.Data,                       SparCsvData.RecordIdValue);
//         Csv2Json("SparOneKeyCsvData",                   SparOneKeyCsvData.Data,                 SparOneKeyCsvData.RecordIdValue);
//         Csv2Json("SparDrawCsvData",                     SparDrawCsvData.Data,                   null);
//         Csv2Json("SparSuitCsvData",                     SparSuitCsvData.Data,                   SparSuitCsvData.RecordIdValue);
//         Csv2Json("SparUpgradeCsvData",                  SparUpgradeCsvData.Data,                SparUpgradeCsvData.RecordIdValue);
//         Csv2Json("SparUnloadingCsvData",                SparUnloadingCsvData.Data,              SparUnloadingCsvData.RecordIdValue);
//         Csv2Json("SparRefineCsvData",                   SparRefineCsvData.Data,                 SparRefineCsvData.RecordIdValue);
//         Csv2Json("SparRefineGrowthCsvData",             SparRefineGrowthCsvData.Data,           SparRefineGrowthCsvData.RecordIdValue);
//         Csv2Json("SparSuperBoxCsvData",                 SparSuperBoxCsvData.Data,               SparSuperBoxCsvData.RecordIdValue);
//         Csv2Json("SupremePrivilegeCsvData",             SupremePrivilegeCsvData.Data,           SupremePrivilegeCsvData.RecordIdValue);
//         Csv2Json("TeamBattleCsvData",                   TeamBattleCsvData.Data,                 null);
//         Csv2Json("TeamBattleParamCsvData",              TeamBattleParamCsvData.Data,            null);
//         Csv2Json("TeamBuffCsvData",                     TeamBuffCsvData.Data,                   null);
//         Csv2Json("TeamTournamenCsvData",                TeamTournamenCsvData.Data,              TeamTournamenCsvData.RecordIdValue);
//         Csv2Json("TeamLevelCsvData",                    TeamLevelCsvData.Data,                  null);
//         Csv2Json("TeamTournamenParamCsvData",           TeamTournamenParamCsvData.Data,         null);
//         Csv2Json("TowersCsvData",                       TowersCsvData.Data,                     TowersCsvData.RecordIdValue);
//         Csv2Json("TreasureCsvData",                     TreasureCsvData.Data,                   TreasureCsvData.RecordIdValue);
//         Csv2Json("TreasureDropCsvData",                 TreasureDropCsvData.Data,               TreasureDropCsvData.RecordIdValue);
//         Csv2Json("TreasurePseudoCsvData",               TreasurePseudoCsvData.Data,             TreasurePseudoCsvData.RecordIdValue);
//         Csv2Json("TreasurePseudoDropGroupCsvData",      TreasurePseudoDropGroupCsvData.Data,    TreasurePseudoDropGroupCsvData.RecordIdValue);
//         Csv2Json("TutorialCsvData",                     TutorialCsvData.Data,                   TutorialCsvData.RecordIdValue);
//         Csv2Json("UnitTypeCsvData",                     UnitTypeCsvData.Data,                   UnitTypeCsvData.RecordIdValue);
//         Csv2Json("VIPCsvData",                          VIPCsvData.Data,                        null);
//         Csv2Json("VipRewardCsvData",                    VipRewardCsvData.Data,                  null);
//         Csv2Json("HeroChainCsvData",                    HeroChainCsvData.Data,                  null);
//         Csv2Json("TeamBattleRankingCsvData",            TeamBattleRankingCsvData.Data,          null);
//         Csv2Json("FeederMapCsvData",                    FeederMapCsvData.Data,                  null);
//         Csv2Json("TeamBattleHeroCsvData",               TeamBattleHeroCsvData.Data,             null);
//         Csv2Json("SkyTurntableCsvData",                 SkyTurntableCsvData.Data,               null);
//         Csv2Json("SkySingleMapCsvData",                 SkySingleMapCsvData.Data,               null);
//         Csv2Json("SystemParamCsvData",                  SystemParamCsvData.Data,                SystemParamCsvData.RecordIdValue);
//         Csv2Json("WebPurchaseCsvData",                  WebPurchaseCsvData.Data,                null);
//         Csv2Json("FundUpCsvData",                       FundUpCsvData.Data,                     null);
//         Csv2Json("PowerRankingsCsvData",                PowerRankingsCsvData.Data,              null);
//         Csv2Json("PowerChestCsvData",                   PowerChestCsvData.Data,                 null);
//         Csv2Json("DialPrizeCsvData",                    DialPrizeCsvData.Data,                  null);
//         Csv2Json("DialRankingCsvData",                  DialRankingCsvData.Data,                null);
//         Csv2Json("BanquetHeroCsvData",                  BanquetHeroCsvData.Data,                null);
//         Csv2Json("BanquetIntegralRewardCsvData",        BanquetIntegralRewardCsvData.Data,      null);
//         Csv2Json("BanquetIntegraLuckyCsvData",          BanquetIntegraLuckyCsvData.Data,        null);
//         Csv2Json("ChainSkillLevelCsvData",              ChainSkillLevelCsvData.Data,            null);
//         Csv2Json("DiscountBagCsvData",                  DiscountBagCsvData.Data,                null);
//         Csv2Json("SparStrengMasterCsvData",             SparStrengMasterCsvData.Data,           null);
//         Csv2Json("ChainPassiveSkillCsvData",            ChainPassiveSkillCsvData.Data,          null);
//         Csv2Json("NewEquipmentForgingCsvData",          NewEquipmentForgingCsvData.Data,        null);
//         Csv2Json("EmblemDecompositionCsvData",          EmblemDecompositionCsvData.Data,        null);
//         Csv2Json("NewEquipmentAttributeCsvData",        NewEquipmentAttributeCsvData.Data,      null);
//         Csv2Json("SuperBoxActivityCsvData",             SuperBoxActivityCsvData.Data,           null);
//         Csv2Json("HeroShopDropCsvData",                 HeroShopDropCsvData.Data,               null);
//         Csv2Json("HeroLevelCsvData",                    HeroLevelCsvData.Data,                  null);
//         Csv2Json("NormalShopDropCsvData",               NormalShopDropCsvData.Data,             null);
//         Csv2Json("ArenaRewardCsvData",                  ArenaRewardCsvData.Data,                null);
//         Csv2Json("ItemComposeCsvData",                  ItemComposeCsvData.Data,                null);
//         Csv2Json("CrusadeChallengePowerCsvData",        CrusadeChallengePowerCsvData.Data,      null);
//         Csv2Json("BanquetSpecialDropCsvData",           BanquetSpecialDropCsvData.Data,         null);
//         Csv2Json("NoviceRechargeCsvData",               NoviceRechargeCsvData.Data,             null);
//         Csv2Json("FirstMonthCardCsvData",               FirstMonthCardCsvData.Data,             null);
//         Csv2Json("PopupBagCsvData",                     PopupBagCsvData.Data,                   null);
//         Csv2Json("FriendBossCsvData",                   FriendBossCsvData.Data,                 null);
//         Csv2Json("GuildAthleticRankCsvData",            GuildAthleticRankCsvData.Data,          null);
//         Csv2Json("SparParamCsvData",                    SparParamCsvData.Data,                  null);
//         Csv2Json("WorldBossMapCsvData",                 WorldBossMapCsvData.Data,               null);
//         Csv2Json("WorldBossParamCsvData",               WorldBossParamCsvData.Data,             null);
//         Csv2Json("GuardianOfGodCsvData",                GuardianOfGodCsvData.Data,              null);
//         Csv2Json("IntimacyFoodCsvData",                 IntimacyFoodCsvData.Data,               null);
//         Csv2Json("IntimacyChallengeCsvData",            IntimacyChallengeCsvData.Data,          null);
//         Csv2Json("IntimacyLevelCsvData",                IntimacyLevelCsvData.Data,              null);
//         Csv2Json("HeroEvolveSpecialCostCsvData",        HeroEvolveSpecialCostCsvData.Data,      null);
//         Csv2Json("ElementTypeCsvData",                  ElementTypeCsvData.Data,                null);
//         Csv2Json("CampTypeCsvData",                     CampTypeCsvData.Data,                   null);
//         Csv2Json("RankTypeCsvData",                     RankTypeCsvData.Data,                   RankTypeCsvData.RecordIdValue);
//         Csv2Json("RarityTypeCsvData",                   RarityTypeCsvData.Data,                 RarityTypeCsvData.RecordIdValue);
//         Csv2Json("PetEvolveCsvData",                    PetEvolveCsvData.Data,                  null);
     }

    private void Csv2Json(string fileName, System.Object dataDict, Dictionary<int,string> recordIdValue) {
//         var ret = new Dictionary<string,int>();
//         if(recordIdValue != null) {
//             foreach(var entry in recordIdValue) {
//                 ret[entry.Value] = entry.Key;
//             }
//         }
//         var data = new {Id=ret, Data=dataDict};
//         string json = LitJson.JsonMapper.ToJson(data);
//         FileStream file = new FileStream(Application.dataPath + "/../Json/" + fileName + ".json", FileMode.Create);
//         byte[] bytes = System.Text.Encoding.UTF8.GetBytes(json);
//         file.Write(bytes, 0, bytes.Length);
//         file.Close();
//         Debug.Log("Generated " + file.Name);
    }

    public void BuildLevelsOverviewJson(GameConfig.EShipChannel shipchannel) {
//         LocalizationCsvData.Read("Assets/Build/Localization/Localization_CN");
//         JumpCSV.CsvManager.Init(GameConfig.GetCsvTargetPath(shipchannel));
//         string mapLevelFolder = "Assets/Resources/Map/BattleMap";
//         List<string> mapFileList = new List<string>();
//         foreach(var p in AssetDatabase.FindAssets("", new string[]{mapLevelFolder})) {
//             string f = AssetDatabase.GUIDToAssetPath(p);
//             if(Path.GetExtension(f) == ".json") {
//                 mapFileList.Add(f);
//             }
//         }
// 
//         List<BattleMapOverview> battleMapOverviewList = new List<BattleMapOverview>();
//         foreach(var m in MapLevelCsvData.Data.Keys) {
//             //if(MapLevelCsvData.LevelType(m) != "story") continue;
//             string p = mapLevelFolder + "/"+ MapLevelCsvData.MapFileName(m) + ".json";
//             Debug.Log(p);
//             var textAsset = (AssetDatabase.LoadAssetAtPath(p, typeof(TextAsset)) as TextAsset);
//             if(textAsset == null) continue;
//             string jsonStr = textAsset.text;
//             var j = new JSONObject(jsonStr);
//             BattleMapJsonData data = new BattleMapJsonData(j);
//             var overview = new BattleMapOverview();
//             overview.MapId = m;
//             overview.FightPower = data.FightPower;
//             List<HeroData> heroes = new List<HeroData>();
//             List<int> bosses = new List<int>();
//             bool hasBoss = false;
//             foreach(var t in data.EnemyTroopsData) {
//                 if(t.HeroType > 0) {
//                     HeroData h = null;
//                     List<EquipmentData> equipments = BattleDatabase.GetEquipmentDataByLevel(t.HeroEquipmentLevel);
//                     h = new HeroData(t.HeroType, t.HeroType, t.HeroLevel, t.HeroStar, 0,  0);
//                     h.AssignPet(t.CharacterType, 0);
//                     h.SetEquipmentData(equipments);
//                     heroes.Add(h);
//                     if(t.CharacterType == 0 && t.CharacterNum > 0) {
//                         UnityEngine.Debug.LogWarning("Character id is zero and character number is larger than 0 " + p);
//                     }
//                     if(t.CharacterNum == 0) {
//                         overview.overviewObjects.Add(new BattleMapOverviewObject(t.HeroType, 0, t.TowerType, t.HeroLevel, 0, t.HeroStar, t.CharacterNum));
//                     }
//                     else {
//                         overview.overviewObjects.Add(new BattleMapOverviewObject(t.HeroType, t.CharacterType, t.TowerType, t.HeroLevel, 0, t.HeroStar, t.CharacterNum));
//                     }
//                 }
//                 else if(t.CharacterType > 0 && t.CharacterNum > 0) {
//                     overview.overviewObjects.Add(new BattleMapOverviewObject(0, t.CharacterType, 0, t.CharacterLevel, 0, t.CharacterStar, t.CharacterNum));
//                 }
//                 else if(t.TowerType > 0) {
//                     overview.overviewObjects.Add(new BattleMapOverviewObject(0, 0, t.TowerType, t.TowerLevel, 0, t.TowerStar, 1));
//                 }
//                 if(t.CharacterType >= 1000) {
//                     bosses.Add(t.CharacterType);
//                 }
//             }
//             int maxLv = 0;
//             int maxPower = 0;
//             HeroData currentHero = null;
//             foreach(var h in heroes) {
//                 if(FightPowerHelper.CalculateHeroFightPower(h) > maxPower) {
//                     maxPower = FightPowerHelper.CalculateHeroFightPower(h);
//                     currentHero = h;
//                 }
//             }
// 
//             if(currentHero != null && bosses.Count == 0) {
//                 overview.Leader = currentHero.Id;
//             }
//             else {
//                 if(bosses.Count > 0) {
//                     overview.Leader = bosses[0];
//                 }
//                 else {
//                     overview.Leader = 0;
//                 }
//             }
//             battleMapOverviewList.Add(overview);
//         }
// 
//         JSONObject json = JSONObject.arr;
//         foreach(var m in battleMapOverviewList) {
//             json.Add(m.ToJsonObject());
//         }
//         string path = EditorUtility.SaveFilePanel("Save Map Info","Assets/Resources/", "battle_map_overview","json");
//         if(path != "") {
//             System.IO.File.WriteAllText(path, json.ToString());
//             UnityEngine.Debug.Log("Create Map Overview At: " + path + " include " + battleMapOverviewList.Count.ToString() + " maps");
//             AssetDatabase.Refresh();
//         }
//         //AssetDatabase.LoadAssetAtPath("Assets/Textures/texture.jpg", Texture2D) as Texture2D;
     }

}

}
