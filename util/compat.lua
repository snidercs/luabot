---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

-- provide table.pack if missing
if not table.pack then
    print("table.pack not available")
    function table.pack(...)
        local nargs = select('#', ...)
        if nargs <= 0 then return {} end
        local out = { n = nargs }
        for i = 1, nargs do
            out[i] = select (i, ...)
        end
        return out
    end
end

if not table.unpack then
    print("table.unpack not available")
    table.unpack = unpack
end
