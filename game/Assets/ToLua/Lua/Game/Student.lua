local _item = {
    cnm = "Student",
    nm = "---",
    age = 0,
}

function _item.init(i,d)
    i.nm=d.nm
    i.age=d.age
end

function _item.show(i)
    print(i.nm,"-",i.age)
end

class(_item)
Student = _item



GoodStudent = {cnm="GoodStudent",func=nil}
function GoodStudent.init(g,d)
    g.base:init(d)
    g.func = d.func
end
function GoodStudent.show(g)
    print(g.nm,g.age,g.func)
end
class(GoodStudent,Student)