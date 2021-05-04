CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

function main {
    telex2_ascent().
    telex2_orbit().
    telex2_deorbit().
    telex2_reentry().
    WAIT UNTIL FALSE.
}

function telex2_ascent {
    print "Starting Ascent Program".
    lock steering to up.
    lock throttle TO 1.
    STAGE.
    SET AVAILTHRUST TO SHIP:AVAILABLETHRUST.
    UNTIL APOAPSIS > 75000 {

        lock targetPitch to 88.963 - 1.03287 * alt:radar^0.409511.
        set targetDirection to 90.
        lock steering to heading(targetDirection, targetPitch).

        IF SHIP:AVAILABLETHRUST < (AVAILTHRUST - 50) {
            lock throttle TO 0.5.
            WAIT 0.15.
            STAGE.
            SET AVAILTHRUST TO SHIP:AVAILABLETHRUST.
            SET THROTTLE TO 1.
            WAIT 1.
        }
    }
    set throttle to 0.
 
}

function telex2_orbit {
    print("Starting Orbital Operations").
    lock steering to prograde.
    wait until ship:altitude > 74000.
    set throttle to 1.
    wait until ship:periapsis > 72000.
    set throttle to 0.
    unlock steering.
    wait 1.
    stage.

    wait until ship:altitude < ship:periapsis+50.
    lock steering to retrograde.
    wait 3.
    set throttle to 1.
    print("Circularizing on second orbit").
    wait until apoapsis < 73000.
    set throttle to 0.
}
function telex2_deorbit {
    wait until ship:altitude >= ship:apoapsis - 500.
    lock steering to retrograde.
    wait 1.
    set throttle to 1.
    print "Firing de-orbital burn".
    wait until periapsis < 25000.
    print "Done".
    set throttle to 0.
}
function telex2_reentry {
    wait until ship:altitude < 71000.
    stage.
    print "Orienting ship for re-entry".
    lock steering to retrograde.
    wait until ship:altitude < 2000.
    print "Deploying chutes".
    stage.
}

main().
