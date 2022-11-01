- car.s is old and untested
- carhard.s is a varient designed to work on the hard track. it doesn't work very well.
- stupid.s tries to go off the road as a shortcut. it doesn't work very well either

most of the "this doesn't work" is resolved by a small fix in the `read_{x,y,z}` subroutine contained in these files i.e. using a non-clobbered register to save the x, y, or z values while making the following `read_uart` calls.




