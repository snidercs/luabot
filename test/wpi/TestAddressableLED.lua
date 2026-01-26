---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local AddressableLED = require ('wpi.frc.AddressableLED')

do
    local led1 = AddressableLED.new(1)
    led1:start()
    led1:stop()
end
