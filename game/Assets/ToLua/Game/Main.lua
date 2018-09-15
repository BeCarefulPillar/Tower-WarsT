require "LENV"

function Main()
    print("Main")

    --测试json
    local tab = {a=1,b=2,c={"hh","ss"}}
    local str = json.encode(tab)
    local t = json.decode(str)
    print(str)
    print(tts(t))

    Win.Open("Prompt", {str="我是参数"})
end