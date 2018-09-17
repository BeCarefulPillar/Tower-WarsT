local _item = {
    cnm = "Student",
    nm = "---",
    age = 0,
}

function _item.init(i)
    i.nm="ppp"
    i.age=200
end

function _item.show(i)
    print(i.nm,"-",i.age)
end

class(_item)
Student = _item



GoodStudent = {cnm="GoodStudent",func=nil}
--function GoodStudent.init(g,d)
--    g.base:init()
--    g.func = d.func
--end
function GoodStudent.show(g)
    print(g.nm,g.age,g.func)
end
class(GoodStudent,Student)