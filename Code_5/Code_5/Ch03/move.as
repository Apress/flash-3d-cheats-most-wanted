/*******************************************************************************
																	
	moose/move.as

	--------------------------------
	The Moose ActionScript Library 
	Copyright (c) 2002, Aral Balkan
	http://www.aralbalkan.com
	--------------------------------

	Purpose: Generic movie clip movement class
	
	Requires: moose/init.as, moose/frame_event.as, moose/chronos.as

	Outstanding issues: 
	
	* Document constructor, methods
	* Create more abstract "animate" class that can be used for any attribute

	Questions? Comments? Email me: aral@aralbalkan.com
			
 *******************************************************************************/


// check for required modules
if (moose == undefined) {
	trace ("moose/move.as error: moose/init.as missing!");
}

if ( moose.frameEvent == undefined ) {
	trace ("moose/move.as error: moose/frame_event.as missing!");
}

if ( moose.chronos == undefined ) {
	trace ("moose/move.as error: moose/chronos.as missing!");
}


// Generic movie clip movement class
moose.Move = function ( movementFn, theTimeline, theClip, theDuration, deltaProps, run, nextMove, updateObj, updateFunc, updatePara, callbackObj, callbackFunc, callbackPara) {
	
	// trace ("move called with "+theClip+", deltax = "+deltaX+", deltay = "+deltaY+" run = "+run);

	this.run = run;
	this.movementFn = movementFn; // reference to the movement function to use
	this.theClip = theTimeline[theClip];
	// trace (":::"+theClip);
	// trace ("------------"+this.theClip);
	this.theDuration = theDuration * 1000; // convert duration in seconds to miliseconds
	this.updateObj = updateObj;
	this.updateFunc = updateFunc;
	this.updatePara = updatePara;
	this.callbackObj = callbackObj;
	this.callbackFunc = callbackFunc;
	this.callbackPara = callbackPara;
	// trace ("theDuration = "+theDuration);
	
	// save the properties to animate
	this.deltaProps = deltaProps;
	this.t = 0; 	// elapsed time
	this.nextMove = nextMove; // movement object to run after this one (optional)
	
	if (this.run) {
		this.startMove();	// start the move	
	}
}
moose.Move.prototype = new MooseModule("Move", 0.1, "Generic movie clip movement class");

Move_p = moose.Move.prototype;	// short-cut

Move_p.startMove = function() {
	var theClip = this.theClip;
	// set flag
	this.running = true;
	// save the initial properties of the clip
	this.initialProps = new Object();
	for (var prop in this.deltaProps) {
		this.initialProps[prop] = theClip[prop];
	}
	// start calling the doMove method on frame enter
	moose.frameEvent.addListener(this, "doMove");
}
Move_p.stopMove = function() {
	// set flag 
	this.running = false;
	// stop calling the doMove method
	moose.frameEvent.removeListener(this, "doMove");
}
Move_p.isRunning = function() {
	// are we running?
	return (this.running);
}
Move_p.doMove = function() {
	
	this.t += moose.chronos.getLastFrameDuration(); // increment the passed time

	// save properties as local vars for speed
	var theClip = this.theClip;
	
	var movementFn = this.movementFn;
	var t = this.t;
	var theDuration = this.theDuration;
	var deltaProps = this.deltaProps;
	var initialProps = this.initialProps;
	var updateObj = this.updateObj;
	var updateFunc = this.updateFunc;
	var updatePara = this.updatePara;
	var callbackObj = this.callbackObj;
	var callbackFunc = this.callbackFunc;
	var callbackPara = this.callbackPara;

	// check if we still need to move and do it
	if (t <= theDuration) {
		// continue movement
		for (var prop in deltaProps) {
			// calculate the new property value for each passed movie clip property to animate
			theClip[prop] = movementFn(t, initialProps[prop], deltaProps[prop], theDuration);
		}
		// call the update function every time the values are updated
		updateObj[updateFunc](this, updatePara);
	} else {
		// movement duration over, make sure all properties for the clip hit the mark
		for (var prop in deltaProps) {
			theClip[prop] = initialProps[prop] + deltaProps[prop];
		}
		this.stopMove();			// we've reached our destination, stop this movement
		callbackObj[callbackFunc](this, callbackPara); // call the callback function
		this.nextMove.startMove();	// run the next movement object, if there is one	
	}
}


/*
	Robert Penner's easing equations - these can be passed for the movementFn parameter
*/

// quadratic easing out - decelerating to zero velocity - Robert Penner
Math.easeOutQuad = function (t, b, c, d) { 
	return -c*t*t/(d*d)+2*c*t/d+b;
};

// quadratic easing in - accelerating from zero velocity - Robert Penner
Math.easeInQuad = function (t, b, c, d) {
	t /= d;
	return c*t*t + b;
};
