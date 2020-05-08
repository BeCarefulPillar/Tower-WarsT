using System;
public partial class GameData {
    public int heroUniqueIdIndex = 1;

    public void CreateHero(int heroId) {
        HeroData hero = new HeroData(heroUniqueIdIndex, heroId);
        AddHero(hero);
        ++heroUniqueIdIndex;
    }

    public void AddHero(HeroData hero) {
        recordDataInfo.heros.Add(hero.id, hero);
    }
    
}


