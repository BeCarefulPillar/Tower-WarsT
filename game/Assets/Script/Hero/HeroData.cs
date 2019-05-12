using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class HeroData {
    private int mHp;
    private int mMaxHp;
    private int mAttack;
    private int mDefend;

    public int id;
    public int heroId;

    public HeroData(int id, int heroId) {
        this.id = id;
        this.heroId = heroId;
    }
}
