CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

function main {
    ascent(2000).
    hover(10000).
    //gtfo().
}


function ascent {
    parameter ht.
    print "Climbing to...".
    print ht.
    stage.
    lock throttle to 1.
    lock steering to up.
    UNTIL SHIP:ALTITUDE > ht { 
        lock throttle to 1.
        wait 2.
}
lock throttle to 0.
lock steering to heading(90,90).
wait until ship:altitude > apoapsis - 25.
print "Apo reached".
}
function hover {
    parameter loop_length.
    print "Hovering for...".
    print loop_length.
    set alti to ship:altitude.
    set iter to 0.
    until iter > loop_length {
        //set res_mag to (ship:sensors:acc:mag - ship:sensors:grav:mag).
        //print ship:sensors:acc:mag - ship:sensors:grav:mag.
        //print "Alt: " + (alti - ship:altitude).
        if verticalSpeed > 0 {
            //print "Throttling down".
            set throttle to throttle - 0.05.
            set alti to ship:altitude.
        }
        if verticalSpeed < 0 {
            //print "Throttling up".
            set throttle to throttle + 0.05.
            set alti to ship:altitude.
        }
    set iter to iter + 1.
}
}
function gtfo {
    set throttle to 1.
    lock steering to heading(-45,0).
    wait 3.
    set throttle to 0.
    wait 1.
    stage.
    lock steering to heading(-45,0).
    wait 5.
    stage.
    wait until ship:altitude < 500.
    stage.
    unlock steering.
    wait until false.
}

main().