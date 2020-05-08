using JumpCSV;
using UnityEngine;

public class HeroData {
    private int mHp;
    private int mMaxHp;
    private int mAttack;
    private int mDefend;
    private string mName;

    public int id;
    public int heroId;

    public HeroData(int id, int heroId) {
        this.id = id;
        this.heroId = heroId;
        this.mName = Loc.Str(HeroCsvData.NameKey(heroId));

        Debug.Log(mName);
    }
}
