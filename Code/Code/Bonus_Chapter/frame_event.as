/*****************************************************************************

	moose/frame_frameEvent.as
			
	--------------------------------
	The Moose ActionScript Library 
	Copyright (c) 2002, Aral Balkan
	http://www.aralbalkan.com
	--------------------------------

	Purpose:	Event listener functions.
	
	To subscribe a listener, use moose.frameEvent.addListener ( obj, listenerFunction );
	To unsubscribe a listener, use moose.frameEvent.removeListener ( obj, listenerFunction );
	--> WRONG: NEED NEW METHOD !!!! [ ] To unsubscribe from *within* the listener function, use moose.frameEvent.removeListener ( this, arguments.callee );
						
	Requires:	moose/init.as

	Questions? Comments? Email me: aral@aralbalkan.com

 *****************************************************************************/

// check for required modules
if (moose == undefined) {
	trace ("moose/frame_caster.as error: Moose Library not initialized. Please load init.as prior to any other Moose module.");
}

// create movie clip to act as broadcaster
moose.frameCaster = _root.createEmptyMovieClip("mooseFrameBroadcaster_mc", moose.incrementLastDepth());

// initialize clip as broadcaster
// ASBroadcaster.initialize(moose.frameCaster);

// broadcast enterFrame message
moose.frameCaster.onEnterFrame = function() {
	moose.frameEvent.broadcast();	
}

// set up own fcModule
if (moose.frameEvent == undefined) {
	moose.frameEvent = new MooseModule("frameEvent", 0.1, "Event listener functions");
}

frameEvent = moose.frameEvent; // short-cut

// Create globals object
if (moose.globals.frameEvent == undefined) {
	moose.globals.frameEvent = new Object();
}

// Create the object to hold the listeners
if (moose.globals.frameEvent.listeners == undefined) {
	moose.globals.frameEvent.listeners = new Array();
}

/*
	Public methods
*/

// frameEvent.addListener()
frameEvent.addListener = function (obj, func) {
	moose.error.validateArgs( arguments );
	listeners = moose.globals.frameEvent.listeners;	// short-cut
	this.removeListener(obj, func);	// make sure we don't add two
	var listener = {obj: obj, func: func}; // create listener object
	listeners.push(listener); // add the listener
	return true;
}
frameEvent.addListener.info = "Adds a listener to the listeners list";
frameEvent.addListener.para = [
	["obj", "object", "Required", "Object listener function is a method of."],
	["func", "string", "Required", "Name of listener function to add."]
];
frameEvent.addListener.returns = "true (Boolean)";
frameEvent.addListener.type = "Public";


// frameEvent.removeListener()
frameEvent.removeListener = function ( obj, func ) {
	moose.error.validateArgs( arguments );
	listeners = moose.globals.frameEvent.listeners;	// short-cut
	var success = false;
	for (i in listeners) {
		if (listeners[i].obj == obj && listeners[i].func == func) {
			listeners.splice(i, 1);
			success = true;
		}
	}
	return success;
}
frameEvent.removeListener.info = "Removes a frame listener.";
frameEvent.removeListener.para = [
	["obj", "object", "Required", "Object listener function is a method of."],
	["func", "string", "Required", "Name of listener function to remove."]
];
frameEvent.removeListener.returns = "true (Boolean) if listener was found and removed, false (Boolean) otherwise.";
frameEvent.removeListener.type = "Public";

/*
	Private methods
*/

// the frame event broadcaster (called by frameCaster)
frameEvent.broadcast = function() {
	listeners = moose.globals.frameEvent.listeners;	// short-cut
	for (i in listeners) {
		listeners[i].obj[listeners[i].func]();
	}
}
frameEvent.broadcast.info = "Broadcasts enterFrame messages to all subscribed listeners.";
frameEvent.broadcast.type = "Private";
