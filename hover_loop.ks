CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

function main {
    wait 2.
    ascent(2500).
    hover(7000,2500).
    go_home().
    vent().
}


function ascent {
    parameter ht.
    rcs on.
    print "Climbing to... " + ht.
    //print ht.
    stage.
    lock throttle to 1.
    gear off.
    //lock steering to up.
    lock steering to heading(90,115).
    UNTIL SHIP:APOAPSIS > ht { 
        lock throttle to 1.

    
}

lock throttle to 0.
lock steering to heading(90,90).
wait until ship:altitude > apoapsis - 25.
print "Apo reached".
}

function hover {
    parameter loop_length.
    parameter ht.
    print "Hovering for... " + loop_length.
    set iter to 0.

    // pidloop
    SET g TO KERBIN:MU / KERBIN:RADIUS^2.
    LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
    LOCK gforce TO accvec:MAG / g.

    SET Kp TO 0.009.
    SET Ki TO 0.00015.
    SET Kd TO 0.1.
    SET hoverPID TO PIDLOOP(Kp, Ki, Kd).
    SET hoverPID:SETPOINT to ht.

    // Iniatializing 
    set wanted_throttle to 0.
    lock throttle to wanted_throttle.
    
    clearscreen.
    print "Starting Loop!".

    until iter > loop_length {

        //https://ksp-kos.github.io/KOS/structures/misc/pidloop.html#please-use-setpoint

        set wanted_throttle to hoverPID:update(time:seconds, alt:radar).
        
        
        if mod(iter,1000) = 0 {
            print "Time remaining: " + (loop_length - iter).
            
        } 
        if mod(iter, 500) = 0 {
            print "Error: " + hoverpid:error.
            
        }
        set iter to iter + 1.  
    
    }

    lock throttle to 0.
    
} 

function go_home {

    // Code block requires TWR > 2.0

    lock steering to srfRetrograde.
    set radarOffset to 7.184.	 				                // The value of alt:radar when landed (on gear)
    lock trueRadar to alt:radar - radarOffset.			        // Offset radar to get distance from gear to ground
    lock g to constant:g * body:mass / body:radius^2.		    // Gravity (m/s^2)
    lock maxDecel to (ship:availablethrust / ship:mass) - g.	// Maximum deceleration possible (m/s^2)
    lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		// The distance the burn will require
    lock idealThrottle to stopDist / trueRadar.			        // Throttle required for perfect hoverslam
    lock impactTime to trueRadar / abs(ship:verticalspeed).		// Time until impact, used for landing gear

    // https://github.com/ayybradleyjh/kOS-Hoverslam/blob/master/hoverslam.ks
    clearscreen.
    WAIT UNTIL ship:verticalspeed < -1. 
        print "Preparing for hoverslam...".
        rcs off.
        brakes on.
        lock steering to srfretrograde.
        when impactTime < 5 then {gear on.}

    WAIT UNTIL trueRadar < stopDist.
        print "Performing hoverslam".
        lock throttle to idealThrottle.

    WAIT UNTIL ship:verticalspeed > -0.01.
        print "Hoverslam completed".
        set ship:control:pilotmainthrottle to 0.
        rcs off.

}

function vent {
    
    unlock steering.
    brakes off.
    lights off.
    
    toggle AG1.

    wait until false.
}

main().