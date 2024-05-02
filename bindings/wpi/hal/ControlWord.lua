
local ffi = require ('ffi')

ffi.cdef[[
struct HAL_ControlWord {
    uint32_t enabled : 1;
    uint32_t autonomous : 1;
    uint32_t test : 1;
    uint32_t eStop : 1;
    uint32_t fmsAttached : 1;
    uint32_t dsAttached : 1;
    uint32_t control_reserved : 26;
};

typedef struct HAL_ControlWord HAL_ControlWord;
int32_t HAL_GetControlWord(HAL_ControlWord* controlWord);
]]

local ControlWord = {}
function ControlWord.new()
    return ffi.new ('HAL_ControlWord')
end

return ControlWord
