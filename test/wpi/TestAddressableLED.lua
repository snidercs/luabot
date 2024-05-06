local AddressableLED = require ('frc.AddressableLED')

do
    local led1 = AddressableLED.new(1)
    led1:start()
    led1:stop()
end
