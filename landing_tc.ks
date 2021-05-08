// TODO: stop 3 engines during landing
// TODO: Add real data to secondary thrust curve (high mass)

// This is for a thrust curve style landing, where a pre-plotted velocity curve is utilized 



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
    set massratio to ship:drymass / ship:wetmass.
    set velocity_curve = 2E-09*alt:radar^3 - 2E-05*alt:radar^2 + 0.1113*alt:radar + 0.3728
    if massratio > 0.5 {
        // Fix this, I just made some random alterations!
        set velocity_curve to = 2E-09*alt:radar^3 - 2E-4*alt:radar^2 + 1.113*alt:radar + 0.3728
    }
    brakes on.
    lock steering to srfRetrograde.
    until alt:radar < 15 {    
        set targ_vert_velocity to velocity_curve.
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
        if alt:radar < 200 {
            // Do engine out stuff!
            engine_out()
        }
        // Abort Mode:
        if alt:radar < 1000 {
            if (abs(ship:verticalspeed+targ_vert_velocity)) > 30 {
            abort_mode()
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

function abort_mode {
        stage.
        lock throttle to 1.
        lock steering to up.
        if abs(verticalSpeed) < 10 {
            lock throttle to 0.
            wait 0.5.
            stage.
        }
        else {
            wait 32.
            stage.
        }
}

function engine_out {
    set err_list to list().
    set list_limit to 0.

    while list_limit < 16 {
        eng:shutdown().
        err_list:add(ship:verticalspeed+targ_vert_velocity).
        set list_limit to list_limit + 1.
    }
    set average to getMean(err_list)
    if abs(average) > 2 {
        eng:start().
    }

    if list_limit > 15 {
        set err_list to list().
        set list_limit to 0.
    }


}

function getMean {
  parameter aList.

  function getSum {
    parameter aList. // note, this is a local aList MASKING the other one.

    local sum is 0.
    for num in aList {
      set sum to sum + num.
    }.
    return sum.
  }.

  return getSum(aList) / aList:LENGTH.
}.
main().