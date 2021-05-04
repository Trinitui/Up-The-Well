stage.
lock throttle to 1.
print "Blast off!".
lock steering to up.
UNTIL SHIP:ALTITUDE > 70000 {
    IF SHIP:ALTITUDE > 1000 AND SHIP:ALTITUDE < 3000 {
        LOCK STEERING TO R(0,0,-90) + HEADING(90,45).
    }
    IF SHIP:ALTITUDE > 3000 {
        LOCK STEERING TO R(0,0,-90) + HEADING(90,0).
    }
IF STAGE:LIQUIDFUEL < 0.1 {
        STAGE.
}
}

wait until false.