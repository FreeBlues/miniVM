--

modes = {}
mode = "stop"

-- main loop
while mode ~= "stop" do  modes[mode]() end

