
function main {
    print "Launch!".
    doLaunch().
    print "Ascent program active".
    doAscent().
    until apoapsis > 100000 {
        doAutoStage().
    }
    print "Shutting down main ascent engine(s)".
    doShutdown().
    print "Cirularization convergence algorithim start - ".
    global initialTime is time:seconds.
    doCircularization().
    print "terrestrial program loop complete".
    unlock steering.
    wait until false.
}

function doCircularization {
    local circ is list(time:seconds + 180, 0, 0, 0).
    until false {
        local oldScore is score(circ).
        set circ to improve(circ).
        if oldScore <= score(circ) {
            //no improvement
            break.
        }
    }
    print "Circularization Solution Found!".
    print "Time to solution: ".
    print time:seconds - initialTime.
    executeManeuver(circ).
}
function score {
    parameter data.
    local mnv is node(data[0],data[1],data[2],data[3]).
    // add to flight plan
    addManeuverToFlightPlan(mnv).
    // score ecc. of mnv ~
    local result is mnv:orbit:eccentricity.
    // remove from flight plan
    removeManeuverFromFlightPlan(mnv).
    return result.
}
// Hill climbing algo
function improve {
    parameter data.
    local scoreToBeat is score(data).
    local bestCandidate is data.
    local candidates is list(
        list(data[0] + 1,data[1],data[2],data[3]),
        list(data[0] - 1,data[1],data[2],data[3]),
        list(data[0],data[1] + 1,data[2],data[3]),
        list(data[0],data[1] - 1,data[2],data[3]),
        list(data[0],data[1],data[2] + 1,data[3]),
        list(data[0],data[1],data[2] - 1,data[3]),
        list(data[0],data[1],data[2],data[3] + 1),
        list(data[0],data[1],data[2],data[3] - 1)
    ).
    for cand in candidates {
        local candScore is score(cand).
        if candScore < scoreToBeat {
            set scoreToBeat to candScore.
            set bestCandidate to cand.
        }
    }
    return bestCandidate.
}


function executeManeuver {
    parameter mList.
    local mnv is node(mList[0],mList[1],mList[2],mList[3]).
    addManeuverToFlightPlan(mnv).
    local startTime is calculateStartTime(mnv).
    wait until time:seconds > startTime - 10.
    lockSteeringAtManeuverTarget(mnv).
    wait until time:seconds > startTime.
    lock throttle to 1.
    wait until isManeuverComplete(mnv).
    lock throttle to 0.
    removeManeuverFromFlightPlan(mnv).
}
function addManeuverToFlightPlan {
    parameter mnv.
    add mnv.
}
function calculateStartTime {
    parameter mnv.
    return time:seconds + mnv:eta - manueverBurntime(mnv)/2.
}
function manueverBurntime {
    parameter mnv.
    local dV is mnv:deltaV:mag.
    local g0 is 9.80665.
    local isp is 0.

    list engines in myEngines.
    for en in myEngines {
        if en:ignition and not en:flameout {
            set isp to isp + (en:isp * (en:maxThrust/ship:maxThrust)).
        }
    }
    // mf = m0 / e^(dV / (isp * g0))
    local mf is ship:mass / constant():e^(dV / (isp * g0)).
    // F = isp * g0 * FuelFlow
    local FuelFlow is ship:maxThrust/(isp*g0).
    // t = (m0 - mf) / fuelflow
    local t is (ship:mass - mf)/FuelFlow.

    return t.
}
function lockSteeringAtManeuverTarget {
    parameter mnv.
    lock steering to mnv:burnvector. 
}
function isManeuverComplete {
    parameter mnv.
    // what was direction to start with?
    // How much have we diverged from og direction? 
    // is it a lot? We've overshot and are DONE
    // target will be behind us when we overshoot - so calc that - basically an angle
    // VANG gives us degrees
    if not(defined originalVector) or originalVector = -1 {
        global originalVector to mnv:burnvector.
    }
    if vang(originalVector, mnv:burnvector) > 90 {
        declare originalVector to -1.
        return true.
    }
    return false.
}
function removeManeuverFromFlightPlan {
    parameter mnv.
    remove mnv.
}


function doLaunch {
    lock throttle to 1.
    doSafeStage().
}
function doAscent {
    lock targetPitch to 88.963 - 1.03287 * alt:radar^0.409511.
    set targetDirection to 90.
    lock steering to heading(targetDirection, targetPitch).
}
function doAutoStage {
    if not(defined oldThrust) {
        global oldThrust to ship:availablethrust.
        set oldThrust to ship:availableThrust.
    }
    if ship:availableThrust < (oldThrust - 10) {
        doSafeStage(). wait 1.
        set oldThrust to ship:availablethrust.
    }

}
function doShutdown {
    lock throttle to 0.
    lock steering to prograde.
    //wait until false.
}
function doSafeStage {
    wait until stage:ready.
    print "Staging.".
    stage.
}

function getVehicleInfo {
    set my_vess to VESSEL("Kerbal X").
    print my_vess:name.
    print my_vess:crew.
    print my_vess:mass.
}

main().