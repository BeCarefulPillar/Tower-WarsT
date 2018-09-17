require "Game/LENV"

function Main()
    print("Main")

    --测试json
--    local tab = {a=1,b=2,c={"hh","ss"}}
--    local str = json.encode(tab)
--    local t = json.decode(str)
--    print(str)
--    print(tts(t))

    --测试class
    local a = Student:new({nm="aa",age=16})
    local b = Student:new({nm="bb",age=17})
    local g= GoodStudent:new({nm="xx",age=18,func=2222})

    local o = object:new()

    --参数1,2是否是相同类型
    print(objis(a,b))
    print(objis(b,g))
    print(objis(a,g))

    --参数1是否是参数2的类型或者子类
    --相当于c# isSubing
    print(objsub(g,a))
    print(objsub(g,b))
    print(objsub(g,g))

    a:show()
    a.base:tostring()
    b:show()
    g:show()

    Win.Open("Prompt", {str="我是参数"})
end