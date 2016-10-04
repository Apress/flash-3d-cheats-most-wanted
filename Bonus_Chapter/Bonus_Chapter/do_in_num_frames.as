/*******************************************************************************

	moose/do_in_num_frames.as

		--------------------------------
		The Moose ActionScript Library 
 	  Copyright (c) 2002, Aral Balkan
		http://www.aralbalkan.com
		--------------------------------

	Purpose: doInNumFrames class - runs a specified function
				  after a specified number of frame enters have passed.

	Usage: 	new moose.doInNumFrames( numFrames, callbackObj, callbackFunc, para );
	
					* Note: you are creating a class instance, not calling the
					  method of a static object. Don't forget the *new* :)

					Flash 5 notes from FC-Lib - may not apply to MX:
				  One potential use is if you are duplicating a movieClip
				  on the current frame that has a onClipEvent(load) handler
				  that defines a function on that movieClip that you need to 
				  access. In Flash 5, the load event fires on the frame after
				  the duplicateMovieClip, however the function is only
				  recognized on the frame *after that*. So a call to 
				  doInNumFrames with 2 for the numFrames parameter
				  will work in these situations.

	Required: moose/init.as, moose/frame_caster.as

	Questions? Comments? email me: aral@aralbalkan.com
			
 *******************************************************************************/

// check for required modules
if (moose == undefined) {
	trace ("moose/do_in_num_frames.as Error: Moose Library not initialized. Please load init.as prior to any other Moose module.");
}

if (moose.frameEvent == undefined) {
	trace ("moose/do_in_num_frames.as Error: Required moose/frame_caster module not loaded.");
}

// nb. we do not check for the presence of the moose/error module since it is usually not included in the final build / publish

// doInNumFrames() class constructor
moose.doInNumFrames = function (numFrames, callbackObj, callbackFunc, para) {

	var currentFrame = moose.chronos.getTotalFrames(); // save current frame number of movie
	this.frameToRunAt = currentFrame + numFrames;
	this.callbackObj = callbackObj;
	this.callbackFunc = callbackFunc;
	this.para = para;
	// start listening for enterFrames
	moose.frameEvent.addListener(this, "onNextFrame");
}
doInNumFrames = moose.doInNumFrames; // short-cut
doInNumFrames.prototype = new MooseModule("doInNumFrames class", 0.1, "Executes callback function after specified number of frameEnters have occurred.");
doInNumFrames.info = "Constructor.";
doInNumFrames.para = [
	["numFrames", "number", "Required", "Number of frames later to run the specified function (eg. in 2 frames will run it not in the next frame but the one after that."],
	["callbackObj", "object", "Required", "Object that callback function is a method of."],
	["callbackFunc", "string", "Required", "Function name of callback function."],
	["para", "Any", "Optional", "Any parameter(s) to be passed to the callback function."]
];
doInNumFrames.type = "Public";


// onNextFrame();
moose.doInNumFrames.prototype.onNextFrame = function() {

	// check if numFrames has been reached:
	if (moose.chronos.getTotalFrames() == this.frameToRunAt) {
		// stop listening for enterFrames
		moose.frameEvent.removeListener(this, "onNextFrame");
		// call callback function	
		this.callbackObj[this.callbackFunc](this.para);			
	}
}
onNextFrame = moose.doInNumFrames.prototype.onNextFrame;	 // short-cut
onNextFrame.info = "Calls the callback function after specified number of frames has past.";
onNextFrame.type = "Private";
