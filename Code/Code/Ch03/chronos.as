/*******************************************************************************
																	
	moose/chronos.as

		--------------------------------
		The Moose ActionScript Library 
 	  Copyright (c) 2002, Aral Balkan
		http://www.aralbalkan.com
		--------------------------------

	Purpose: Global timer, time-related methods.

	Requires: moose/init.as, moose/frame_caster.as

	Questions? Comments? Email me: aral@aralbalkan.com
			
 *******************************************************************************/

// check for required modules
if (moose == undefined) {
	trace ("moose/chronos.as Error: Moose Library not initialized. Please load init.as prior to any other Moose module.");
}

if (moose.frameEvent == undefined) {
	trace ("moose/chronos.as Error: Required moose/frame_caster module not loaded.");
}

// nb. we do not check for the presence of the moose/error module since it is usually not included in the final build / publish

// set up own MooseModule
if (moose.chronos == undefined) {
	moose.chronos = new MooseModule("chronos", 0.1, "Timer and time-related functions");
}
// set up own globals object
if (moose.globals.chronos == undefined) {
	moose.globals.chronos = new Object();
}

chronos = moose.chronos;	// short-cut

/**********************
	Public methods
***********************/

// init()
chronos.init = function() {
	cGlobal = moose.globals.chronos; // short-cut
	cGlobal.savedTime = (new Date()).getTime();
	cGlobal.totalTime = 0;
	cGlobal.totalFrames = 0;

	// Add an enterFrame listener for chronos
	moose.frameEvent.addListener(this, "update");

	// return from init, success
	return true;
}
chronos.init.info = "Initializes the movie timer";
chronos.init.longInfo = "Keeps track of total elapsed time and frames. Necessary before using any of the other chronos module functions"
chronos.init.returns = "true (Boolean)";
chronos.init.type = "Public";


// getMovieTime()
chronos.getMovieTime = function() {
	return moose.globals.chronos.totalTime;
}
chronos.getMovieTime.info = "Get the time (in miliseconds) elapsed since the start of the movie";
chronos.getMovieTime.type = "Public";
chronos.getMovieTime.returns = "(Int) Time in miliseconds since the start of the movie";


// getTotalFrames()
chronos.getTotalFrames = function() {
	return moose.globals.chronos.totalFrames;
}
chronos.getTotalFrames.info = "Gets the total number of frames entered since the start of the movie";
chronos.getTotalFrames.type = "Public";
chronos.getTotalFrames.returns = "(Int) Number of frames entered since the start of the movie";


// getLastFrameTime()
chronos.getLastFrameDuration = function() {
	return moose.globals.chronos.timeDiff;
}
chronos.getLastFrameDuration.info = "Calculates how long it took the movie to go from the last frame to the current frame";
chronos.getLastFrameDuration.returns = "(Number) The time difference between the previous and current frame, in miliseconds";
chronos.getLastFrameDuration.type = "Public";


// getMovieCurrentFPS()
chronos.getMovieCurrentFPS = function() {
	return ( 1 / ( this.getLastFrameDuration() / 1000 ) );
}
chronos.getMovieCurrentFPS.info = "Calculates the current FPS of the movie, based on how long the last frame took";
chronos.getMovieCurrentFPS.returns = "(Number) The current FPS of the movie based on the length of the last frame";
chronos.getMovieCurrentFPS.type = "Public";


// getMovieAverageFPS()
chronos.getMovieAverageFPS = function() {
	return ( this.getTotalFrames() / ( this.getMovieTime() / 1000 ) );
}
chronos.getMovieAverageFPS.info = "Calculates the average FPS of the movie since the chronos timer was started";
chronos.getMovieAverageFPS.returns = "(Number) The average FPS of the movie since the chronos timer was started";
chronos.getMovieAverageFPS.type = "Public";


// int stopChronos()
chronos.halt = function() {
	moose.frameEvent.removeListener(this, "update");
}
chronos.halt.info = "Stops the global movie timer";
chronos.halt.returns = "true (Boolean)";
chronos.halt.type = "Public";


// timer class - works like a stopwatch (in miliseconds, devide by 1000 to get seconds)
chronos.timer = function() {
	this.startTime = moose.chronos.getMovieTime(); // save the start time
}

// returns the number of miliseconds elapsed since start of timer
chronos.timer.prototype.getElapsed = function() {
	var now = moose.chronos.getMovieTime();
	return (now - this.startTime);
}

// DoIn Class
chronos.DoIn = function( theTime, theObj, theFunc, thePara ) {

	// trace ("DoIn constructor: "+theTime+", "+theObj+", "+theFunc+", "+thePara);

	// moose.error.validateArgs( arguments );

	this.endTime = moose.chronos.getMovieTime() + (theTime * 1000);	// calculate ending time (ms)
	this.theObj = theObj;									// save the object
	this.theFunc = theFunc;									// and the function
	this.thePara = thePara;									// and the parameters

	// add the checkTime method as a frame listener
	moose.frameEvent.addListener(this, "checkTime");
}
chronos.doIn.info = "Class constructor. Runs the specified function after the specified number of miliseconds has passed.";
chronos.doIn.para = [
	["theTime", "number", "Required", "Miliseconds to wait before running function"],
	["theObj", ["object", "movieclip"], "Optional", "The object / movieclip that the function is a method of"],
	["theFunc", ["string", "function"], "Required", "Name of the function to run (string) or function reference"],
	["thePara", "any", "Optional", "The parameter to pass to a function. To pass multiple parameters, make this an object"]
];
chronos.doIn.returns = "Reference to DoIn object";
chronos.doIn.type = "Public";


// DoIn.checkTime
chronos.DoIn.prototype.checkTime = function () {
	// trace ("DoIn.checkTime() called!!!");	// debug
	var currentTime = moose.chronos.getMovieTime();

	// is it time to run the callback function?
	if (currentTime >= this.endTime) {
		// trace("About to run:"+this.theObj+"."+this.theFunc+"()...");
		if (typeof this.theFunc == "string") {
			this.theObj[this.theFunc](this.thePara);
		} else if (typeof this.theFunc == "function") {
			this.theFunc(this.thePara);
		}
		// remove the frame listener
		moose.frameEvent.removeListener(this, "checkTime");
	}
}
chronos.DoIn.prototype.checkTime.info = "Internal callback function that waits until the requested time and calls the callback function.";
chronos.DoIn.prototype.checkTime.type = "Private";

// DoIn.cancel
chronos.DoIn.prototype.cancel = function() {
	// remove the frame listener
	moose.frameEvent.removeListener(this, "checkTime");
}
chronos.DoIn.prototype.cancel.info = "Cancels the do in event.";
chronos.DoIn.prototype.cancel.type = "Public";

// doEvery()
chronos.doEvery = function( theTime, theObj, theFunc, thePara, run ) {

	moose.error.validateArgs( arguments );

	// if user requested function to be run, run it for the first time.
	if (run) {
		theObj[theFunc](thePara);
	}

	// short-cut
	cGlobal = moose.globals.chronos;	// short-cut

	// validate passed arguments

//	if (moose.error.validateArgs( arguments ) == null) { 
//		trace ("Wrong type/number of arguments passed to doEvery(). Halting.");
//		return null;
//	};


	if (cGlobal.theDoEveryList == undefined) {
		cGlobal.theDoEveryList = new Object();
		cGlobal.theDoEveryList.currentID = -1;
	}
	
	// trace ("doEvery: "+theTime+", "+theObj+", "+theFunc+"("+thePara+") -- run = "+run+"...");	// debug

	cGlobal.theDoEveryList.currentID++;

	var temp = new Object();
	temp.startTime = this.getMovieTime();	// save the current time
	temp.theTime = theTime * 1000;			// save interval as miliseconds
	temp.theObj = theObj;					// save the object
	temp.theFunc = theFunc;					// and the function
	temp.thePara = thePara;					// and the parameters
	temp.run = run;							// flag, whether or not to execute

	cGlobal.theDoEveryList[cGlobal.theDoEveryList.currentID] = new Object();	
	cGlobal.theDoEveryList[cGlobal.theDoEveryList.currentID] = temp;	// save to the doEvery list

	if (run) this.doEveryRun();	
	
	return (cGlobal.theDoEveryList.currentID);	// return the ID 
}
chronos.doEvery.name = "doEvery";
chronos.doEvery.info = "Runs the specified function every time the specified amount of seconds has passed.";
chronos.doEvery.para = [
	["theTime", "number", "Required", "Interval in seconds that the function should be called at."],
	["theObj", ["object", "movieclip"], "Required", "The object/movieclip that the function is a method of"],
	["theFunc", "string", "Required", "Name of the function to run"],
	["thePara", "Any", "Optional", "The parameter to pass to a function. To pass multiple parameters, make this an object"],
	["run", "boolean", "Optional", "Whether or not to start this doEvery instance. Defaults to not running."]
];
chronos.doEvery.returns = "id (Integer) : The ID of the entered doEvery instance.";
chronos.doEvery.longInfo = "You can enter doEvery instances with their run states set to off and then start/stop them using doEveryRun() and doEveryHalt() and the ID returned by the method.";
chronos.doEvery.type = "Public";


// doEveryRun()
chronos.doEveryRun = function (id) {
	moose.error.validateArgs( arguments );
	moose.globals.chronos.theDoEveryList[id].run = true;
	// in case the listener was stopped to save CPU, make sure we restart it
	moose.frameEvent.addListener(this, "doDoEvery");
}
chronos.doEveryRun.info = "Starts a doEvery instance";
chronos.doEveryRun.para = [
	["id", "number", "Required", "doEvery instance ID as returned by doEvery()"]
];
chronos.doEveryRun.type = "Public";


// doEveryHalt()
chronos.doEveryHalt = function (id) {
	cGlobals = 	moose.globals.chronos; // short-cut

	moose.error.validateArgs( arguments );
	cGlobals.theDoEveryList[id].run = false;
	
	// check if all do every instances are off, and if so, stop the doDoEvery listener to save CPU
	allOff = true;
	for (i in cGlobals.theDoEveryList) {
		if (cGlobals.theDoEveryList[id].run) {
			allOff = false;
			break; // no need to go on, we know that the listener needs to remain on
		}
	}
	if (allOff) {
		moose.frameEvent.removeListener(this, "doDoEvery");
	}
}
chronos.doEveryHalt.info = "Stops a doEvery instance";
chronos.doEveryHalt.para = [
	["id", "number", "Required", "doEvery instance ID as returned by doEvery()"]
];
chronos.doEveryHalt.type = "Public";


/*
	Private methods
*/


// update ()
chronos.update = function() {
	// globals
	cGlobal = moose.globals.chronos;

	cGlobal.currentTime = (new Date()).getTime();
	// calculate the amount of time the last frame took
	cGlobal.timeDiff = cGlobal.currentTime - cGlobal.savedTime;
	cGlobal.totalTime += cGlobal.timeDiff;	// add to the total elapsed time
	cGlobal.totalFrames++;					// add to the elapsed number of frames
	cGlobal.savedTime = (new Date()).getTime();
}
chronos.update.info = "Internal fn. called by enterFrame listener to update the movie's timer.";
chronos.update.type = "Private";

// doDoEvery()
chronos.doDoEvery = function () {

	cGlobal = moose.globals.chronos;	// short-cut

	currentTime = this.getMovieTime();

	for ( member in cGlobal.theDoEveryList ) {
		currentMember = cGlobal.theDoEveryList[member]; // short-cut
		if (currentMember.run) {
			if ( currentTime >= (currentMember.startTime + currentMember.theTime) ) {
				// time to run the function
				currentMember.startTime = currentTime;		// save the new time
				currentMember.theObj[currentMember.theFunc](currentMember.thePara);	// run!
			} 
		}
	}
}
chronos.doDoEvery.info = "Internal callback function that handles all doEvery event firings.";
chronos.doDoEvery.type = "Private";

// start chronos
chronos.init();