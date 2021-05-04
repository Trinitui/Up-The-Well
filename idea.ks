// TODO: stop 3 engines during landing
// TODO: normalize mass during landing (either detect and adjust model,  or vent it)



function main {
    take_off().
    detect_apo().
    landing_exp().
    post_landing().
}


function take_off {
    rcs on.
    lock throttle to 1.
    stage.
    lock steering to heading(90,60).
    wait until ship:altitude > 15000.
    lock throttle to 0.
    unlock throttle.
}

function detect_apo {
    wait until verticalSpeed < abs(10).
    print("AT APO").
    unlock steering.
    
}

function landing_exp {
    wait until ship:altitude < 70000.
    CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
    brakes on.
    lock steering to srfRetrograde.
    until alt:radar < 15 {    
        set targ_vert_velocity to 2E-09*alt:radar^3 - 2E-05*alt:radar^2 + 0.1113*alt:radar + 0.3728.
        print(ship:verticalspeed+targ_vert_velocity).
        if ship:verticalspeed < -targ_vert_velocity {
            set throttle to (throttle + 0.01).
        }
        if ship:verticalspeed > -targ_vert_velocity {
            set throttle to (throttle - 0.01).
        }
        if alt:radar < 400 {
            gear on.
            lock steering to up.
        }
        // Abort Mode:
        if alt:radar < 1000 {
            if (abs(ship:verticalspeed+targ_vert_velocity)) > 30 {
                stage.
                lock steering to up.
                wait 32.
                stage.
            }
        }
    }
}

function post_landing {
    rcs off.
    brakes off.
    lights off.
    set throttle to 0.
}

main().