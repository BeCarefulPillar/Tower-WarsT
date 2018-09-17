


Dialogue = {
    --[Comment]
    -- 对话类型
    dlg_type = {
        --[Comment]
        -- 俘虏对话
        captive = 1,
        --[Comment]
        -- 战斗对话
        fight = 2,
        --[Comment]
        -- 关卡对话
        lv1 = 3,
        --[Comment]
        -- 酒馆对话
        tavern = 4,
    },

    --[Comment]
    -- 俘虏对话
    [1] = {
        {c = 1,tx = "P:将军如此良才，可愿与我共建大业?"},
        {c = 1,tx = "P:良禽择木而栖,将军可愿归降与我？"},
        {c = 2,tx = "N:听候您的差遣。"},
        {c = 2,tx = "N:我正有此意。"},
        {c = 2,tx = "N:主公，我愿归降。"},
        {c = 2,tx = "N:愿降!"},
        {c = 2,tx = "N:我愿我愿追随主公。"},
        {c = 2,tx = "N:我愿誓死追随主公完成大业。"},
        {c = 2,tx = "N:哈哈，主公大业怎能少了我!"},
        {c = 2,tx = "N:你乃明主，我愿归降于您。"},
        {c = 3,tx = "N:我的主公只有一个！"},
        {c = 3,tx = "N:休要再言，我绝不做背主求荣之事！。"},
        {c = 3,tx = "N:我宁死不降！"},
        {c = 3,tx = "N:你并非良主!。"},
        {c = 4,tx = "P:我不杀忠勇之人，今日就此作罢。|N:期待与您的再次相见。"},
        {c = 4,tx = "P:将军如此忠心，希望今后好自为之。|N:下次战场相见,我定不会手下留情。"},
        {c = 4,tx = "P:既然如此，你走吧。|N:多谢。"},
        {c = 4,tx = "P:如此良才，竟不能为我所用，唉。|N:就此别过。"},
        {c = 5,tx = "N:要杀要剐，悉听尊便！"},
        {c = 5,tx = "N:......"},
        {c = 6,tx = "N:不过一死，有何惧之！"},
        {c = 6,tx = "P:斩了！|N:哈哈哈哈，多谢成全!"},
        {c = 0,tx = "N:......"},
    },

    --[Comment]
    -- 战斗对话
    [2] = {
        "今日我必斩你于马下。|休要呈口舌之快!",
        "击败你，我将完成主公大业的第一步。|那我将让你止步于此！",
        "今日我必将杀的尔等片甲不留！|那我就拿你的血祭我三军！",
        "大势已去，投降吧。|我宁死不降！",
        "纳命来吧，我的大军已势不可挡！|将士们！击破他们！",
        "哈哈哈，三招之内我必斩你！|哼！狂妄之徒！",
        "我的铁蹄将踏遍你们的城池！|先踏过我的尸体再说吧。",
        "酒且斟下，待我斩你首级，再来饮之！！|虚张声势，此酒当为你的断头酒！",
        "世之无双，你我战过才能分晓。|那就全力以赴战到最后吧。",
        "吾乃世之名将，尔等如何能敌？|插标卖首之徒，怎敢妄言！",
        "事已至此，我也不想再造杀孽，归降吧！|陷阵之志，有死无生！你要战便战！",
        "无人能阻挡我主的大军！|这要试过才知道！",
        "今日我就送你下地狱吧！|我也正有此意。",
        "我主之大业，岂是尔等能够阻挡的吗？|各为其主，就看谁是天命所归吧！",
        "我统之兵，必将杀的尔等溃不成军。|织席贩履之辈，也敢妄言统兵？",
        "我要与你一决死战！|我如你所愿！",
        "来人可敢报上名号？|将死之人，要我名号何用？",
        "吾主大军至此，无知小儿出来受死！|哼！看我来取你狗命！",
        "可敢与我一战？|有何不敢？",
        "献上你主的项上人头，我饶你一命！|混账！今日我与你不死不休！",
        "今日我要你血祭我的剑！|那要看你的剑够不够锋利。",
        "众将士，随我上阵杀敌！|儿郎们，消灭他们！",
        "我的剑今日要为你出鞘！|那就来吧！",
        "为了胜利，为了家人，随我击溃敌人吧！|给我碾碎他们！",
        "我观天象，今日必有将星陨落！|在我看来，陨落的那个一定是你！",
        "献上城池，我主必会饶你一命！|我定会取下你的头颅！",
        "天下大势，众望所归，归降我主，有何不可？|逆贼而已，休要多言！",
        "我只享受大获全胜的感觉！|既然如此，今日我让你一偿失败的痛苦！",
        "两军交战，不死不休，受死吧！|今日一战，你我只能活下一个。",
    },

    --[Comment]
    -- 关卡对话
    [3] = {
        {sn = 1, tx = "N:我不明白世人为何如此待我，我起义乃是为了天下百姓!|P:因为你们背离了当初起义时的初心，大汉依然是大汉，还没有到彻底腐烂的时候!|N:唉，黄天......也死了！"},
        {sn = 2, tx = "N:你们......你们这些乱民，竟然妄想阻止我，你们统统要死！我儿奉先何在？|P:你这祸乱江山的乱臣贼子，天下共击之，我等奉召讨贼，受死吧！|N:竖子，安敢反我！|P:董贼势力已除，但汉室江山已经残破，终究要迎来乱世纷争。"},
        {sn = 3, tx = "N:想我拥四州，民户百万，威震海内，不料也有今日！|P:好一个袁本初，好一个四世三公，名冠天下的袁家。|N:今日之败，实乃天不助我袁家啊......"},
        {sn = 4, tx = "N:圣人恒无心，以百姓心为心，尚善若水，利万物而不争。|P:如今大势已去，师君意欲何从？|N:我不会放弃的，我会继续以我的道义传教世人。"},
        {sn = 5, tx = "P:此人长八尺馀，身体洪大，面鼻雄异，相必就是西凉马寿成了吧，果然是名将之后。|N:西凉男儿们，我等的铁蹄，终究未能踏遍中原大地，我们不该止步于此。|P:胜负已分，你该认命了！|N:那有如何？我儿孟起定能带领西凉男儿成就一番伟业......"},
        {sn = 6, tx = "N:我自以为荆襄之地，自守足矣，静观天下，不欲争雄，奈何事与愿违啊。|P:乱世已至，天下群雄并起，你又如何能独善其身。|N:事已至此，都怪我太优柔寡断了......"},
        {sn = 7, tx = "P:这就是白马义从，果然是义之所至，生死相随！不愧为天下第一的轻骑，今日领教了！|N:我军将败，乃我一人之罪，我已无颜苟活于世。|P:胜败乃兵家常事，将军又何须介怀。"},
        {sn = 8, tx = "P:好一个孙仲谋！雄才大略，权善用兵，见策知变。今日一见，不负盛名！|N:孤十五而立，纵横捭阖，自有制衡之道，然今日之败，难道江东基业要毁于我手？"},
        {sn = 9, tx = "N:孤常忧国家危败，愍百姓苦毒，率义兵诛天下残贼，纵横天下，群雄皆灭，止有江东孙权，西蜀刘备，未曾剿除。虽挟天子以令诸侯，但孤始终没有迈出那一步，对得起汉室......|P:这就是“宁教我负天下人，休教天下人负我”的枭雄曹孟德吗？果然是一代雄主......"},
        {sn = 10, tx = "N十余万生灵啊，皆因跟随我而遭此劫难。即使草木之人，铁石心肠，能不悲乎？我儿切记，勿以恶小而为之，勿以善小而不为，惟贤惟德，方能服人。|P:刘使君果然弘毅宽厚，知人待士，乃有高祖之风，然天意使然，今日对不住了！|N:唉，大汉亡矣......"},
    },

    --[Comment]
    -- 酒馆对话
    [4] = {
        { c = 2, t = 5, tx = "N:痛快,痛快!"},
        { c = 2, t = 5, tx = "N:我先干为敬!"},
        { c = 2, t = 5, tx = "N:好酒！好酒啊！"},
        { c = 2, t = 5, tx = "N:就这点酒就想收买我?想多了吧!"},
        { c = 2, t = 5, tx = "N:来,让我们一醉方休!"},
        { c = 2, t = 20, tx = "N:酒馆里总会出现一些奇人异士。"},
        { c = 2, t = 20, tx = "N:相逢即是有缘。"},
        { c = 2, t = 20, tx = "N:想让我教你?那得再来几杯。"},
        { c = 2, t = 20, tx = "N:嗯嗯~这可是上等的美酒!"},
        { c = 2, t = 20, tx = "N:不醉不归，不醉不归！	"},
        { c = 2, t = 20, tx = "N:哈哈哈，真是他乡遇故知！"},
        { c = 2, t = 20, tx = "N:初次见面，请多多关照。"},
        { c = 2, t = 70, tx = "N:完成大业，需要有一批忠心的将领。"},
        { c = 2, t = 70, tx = "N:阁下可真是好酒量呀。"},
        { c = 2, t = 70, tx = "N:与君共饮，乃我之幸。"},
        { c = 2, t = 70, tx = "N:我在寻找良主"},
        { c = 2, t = 70, tx = "N:不行了,不行了!实在喝不下了。"},
        { c = 2, t = 70, tx = "N:啥?我醉了?不可能，我可是千杯不醉!"},
        { c = 1, t = 0, tx = "N:年轻人,我们见过么?"},
        { c = 1, t = 0, tx = "N:久仰，久仰。"},
        { c = 1, t = 0, tx = "N:真是久仰大名啊。 "},
        { c = 1, t = 0, tx = "N:闻名不如见面啊。"},
        { c = 1, t = 0, tx = "N:我们又见面了。"},
        { c = 2, t = 0, tx = "N:让我们共饮此杯！"},
        { c = 3, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:我厌恶战争!"},
        { c = 3, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:不好意思，我对征战杀伐不感兴趣。"},
        { c = 3, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:恐怕我的能力达不到你的理想。"},
        { c = 3, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:我们的交情还没到这种地步。"},
        { c = 3, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:当今局势，我还不想加入任何势力。"},
        { c = 3, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:今日只饮酒，不论天下大势。"},
        { c = 3, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:这般想法不曾有过。"},
        { c = 3, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:道不同不相为谋。"},
        { c = 4, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:正合我意！"},
        { c = 4, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:我愿与你并肩作战。"},
        { c = 4, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:我等这一刻已经很久了！"},
        { c = 4, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:我终于遇到了值得追随的明主了！"},
        { c = 4, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:我愿意为你而战。"},
        { c = 4, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:主公!"},
        { c = 4, t = 0, tx = "P:既然有如此大志，何不随我征战一场？|N:我愿誓死追随主公!"},
        { c = 5, t = 0, tx = "N:又有一批新的将领慕名而来,主公。"},
        { c = 6, t = 0, tx = "N:哈哈!谢主公恩赐!"},
        { c = 6, t = 0, tx = "N:听候您的差遣。"},
        { c = 6, t = 0, tx = "N:主公,请您下令。"},
        { c = 6, t = 0, tx = "N:誓死效忠主公。"},
        { c = 6, t = 0, tx = "N:犯我城邦者,虽远必诛!"},
        { c = 6, t = 0, tx = "N:我今日立誓，誓死完成主公大业!"},
        { c = 6, t = 0, tx = "N:主公的恩德,没齿难忘!"}
    },
}
