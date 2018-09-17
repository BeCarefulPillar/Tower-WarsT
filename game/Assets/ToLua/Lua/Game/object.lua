local _o = {
    cnm = "object"
}

function _o.tostring(o)
    print(tts(o))
end

class(_o)

object = _o