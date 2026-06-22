luaTickRate = 200 -- Tick rate is 200 Hz
-- Set the original injector flow size in cc3/min
-- E36 green tops 190.2 cc3/min
stockInjectorFlow = 190.2 

-- Time to let the purge valve work in idle in seconds
purgeTime = 5 
purgeWaitTime = 5 * luaTickRate -- time to wait in idle before start the purge process

remainingPurgeTime = purgeTime * luaTickRate
waitToPurgeTime = purgeWaitTime

-- index 0, 12Hz, zero duty initially (PD15 - D31 - OBC TI Signal)
-- index 1, 12Hz, zero duty initially (PE15 - D35 - TankPurgeValve)
startPwm(1, 8, 0)
startPwm(0, 3, 0) -- index, freq, duty

setTickRate(200) -- set tick freq to 200 hz because we should update the dutycycle min approx. max-rpm * 2

-- onTick is provided by rusEFI and is called every 
function onTick() 
    tiFreq = (getSensor("RPM") / 60)
    tiDuty = ((getCalibration("injector.flow") / stockInjectorFlow) * getOutput("injectorDutyCycle"))

    setPwmFreq(0, tiFreq)
    setPwmDuty(0, tiDuty)
    print("TI Frq: "..tiFreq)
    print("TI Duty: "..tiDuty)

    if getOutput("notIdling") == 0 and remainingPurgeTime > 0 and waitToPurgeTime == 0 then
        setPwmDuty(1, 30)
        remainingPurgeTime = remainingPurgeTime - 1
        print("purge on")
    else
        if getOutput("notIdling") == 0 and waitToPurgeTime > 0 then
            waitToPurgeTime = waitToPurgeTime - 1
        else
            waitToPurgeTime = purgeWaitTime -- reset to waittime
        end
        setPwmDuty(1, 0)
        remainingPurgeTime = purgeTime -- reset to purgetime 
        print("purge off")
    end
end