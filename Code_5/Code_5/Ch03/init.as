/*****************************************************************************

	moose/init.as
			
			--------------------------------
			The Moose ActionScript Library 
 		  Copyright (c) 2002, Aral Balkan
			http://www.aralbalkan.com
			--------------------------------

			Initializes the Moose system.
	
			Requires:	none.

			Questions? Comments? Email me: aral@aralbalkan.com

 *****************************************************************************/

trace ("loaded: mooose/init.as");

/*
	Moose class:	All modules that adhere to the Moose Coding Model are instances of the core MooseModule class.
*/

_global.MooseModule = function ( name, ver, description ) {
	trace ("new MooseModule created: "+name); // debug
	this.isMooseModule = true;				// flag
	this.name = name;					// module name
	this.ver = ver;						// module version
	this.description = description;		// brief module description
}


// Returns the module name
MooseModule.prototype.getModuleName = function() {
	return this.name;
}


// Returns the version of the module
MooseModule.prototype.getModuleVersion = function () {
	return this.ver;
}


// Returns the description of the module
MooseModule.prototype.getModuleDescription = function() {
	return this.description;
}


// Returns an obj with the names of all Moose Modules within the specified object
MooseModule.prototype.getMooseModules = function ( obj ) {
	if (obj == undefined) { obj = this; }	// default to current module
	var MooseModules = new Array();
	for (element in obj) {
		theElement = this[element];
		if ( ( (typeof theElement) == "object") && (theElement.isMooseModule == true) ) {
			// retrieve the method info for the current method
			MooseModules.push ( theElement.name );
		}
	}
	return MooseModules; // (Object) 
}

// List the Moose Modules found on object obj
MooseModule.prototype.listMooseModules = function ( obj ) {
	var buffer = new Array();
	var INDENT = "    ";
	if (obj == undefined) { obj = this; }	// default to current moose Module as root
	var MooseModules = this.getMooseModules( obj );	// retrieve list of moose Modules

	buffer.push ("");
	buffer.push ("List of moose Modules found on "+ obj.name );
	for (MooseModule = 0; MooseModule < MooseModules.length; MooseModule++) {
		buffer.push (INDENT + MooseModules[MooseModule])
	}
	buffer.push ("");
	this.printBuffer ( buffer );
}

// Returns an obj with all public method names and descriptions in the module
MooseModule.prototype.getPublicMethods = function () {
	var publicMethods = new Object();
	for (element in this) {
		theElement = this[element];
		if ( ( (typeof theElement) == "function") && (theElement.type == "Public") ) {
			// retrieve the method info for the current method
			publicMethods[element] = this.getMethodInfo(theElement, element);
		}
	}
	return publicMethods; // (Object) 
}


MooseModule.prototype.saveMethodNames = function () {
	for (element in this) {
		// check if this is an moose method
		if (this[element].type == "Public" || this[element].type == "Private") {
			// save it's name as a property
			this[element].name = element;
		}
	}
}


// Lists the public method names to the specified output device
MooseModule.prototype.listPublicMethods = function( output ) {
	var buffer = new Array();
	var publicMethods = this.getPublicMethods();

	buffer.push("");	// leave an empty line
	for (publicMethod in publicMethods) {
		buffer.push ( publicMethods[publicMethod].name );
	}
	buffer.push("");	// leave an empty line
	this.printBuffer ( buffer , output);
}


// Lists all documentation for public methods in the module. If no arguments are provided, the list is traced out to the Output window. If a print function is specified, the output is sent there instead.
MooseModule.prototype.showDoc = function(printFunc) {
	// constants
	INDENT = "    ";

	// variables
	var buffer = new Array();			// used to hold lines to be printed
	var publicMethods = new Object();	// used to hold info on public methods

	publicMethods = this.getPublicMethods();	// get method info of public methods

	buffer.push("\n");	// leave two empty lines before
	buffer.push("Showing documentation for module: " + this.getModuleName() + " (v" + this.getModuleVersion() + ") - "+this.getModuleDescription());

	for (var publicMethod in publicMethods) {
		thePublicMethod = publicMethods[publicMethod]; // short-cut
		publicMethodInfo = this.formatMethodInfo(thePublicMethod);
		// copy over the formated method info
		for (element = 0; element < publicMethodInfo.length; element ++) {
			buffer.push (publicMethodInfo[element]);
		}
	}

	buffer.push("\n");	// leave two empty lines after

	this.printBuffer ( buffer, printFunc ); // ok, print it!
}


// *** Move this somewhere else!!!
// sends contents of a buffer array either to specified output device or to the output window (trace)
MooseModule.prototype.printBuffer = function ( buffer, output ) {
	// send the print-out either to the custom print function or to the output window
	if (ouput != undefined) {
		for (var lineToPrint = 0; lineToPrint < buffer.length; lineToPrint++) {
			printFunc(buffer[lineToPrint]);
		}
	} else {
		for (var lineToPrint = 0; lineToPrint < buffer.length; lineToPrint++) {
			trace(buffer[lineToPrint]);
		}
	}
}


// lists method info for the passed method:
MooseModule.prototype.listMethodInfo = function ( theMethod, methodName ) {

	var methodInfo = this.getMethodInfo (theMethod, methodName);
	buffer = new Array();
	buffer = this.formatMethodInfo(methodInfo);
	this.printBuffer(buffer);
	return true;
}

// returns available information about a method in an object
MooseModule.prototype.getMethodInfo = function ( theMethod, methodName ) {
	methodInfo = new Object();	
	methodInfo.name = (methodName == undefined) ? theMethod.name + "()" : methodName + "()";
	methodInfo.para = theMethod.para;
	methodInfo.type = theMethod.type;
	methodInfo.info = theMethod.info;
	methodInfo.longInfo = theMethod.longInfo;
	methodInfo.returns = theMethod.returns;
	methodInfo.errors = theMethod.errors;

	return methodInfo;	// (object)
}


// returns a formatted buffer array of information about the specified methods
MooseModule.prototype.formatMethodInfo = function ( theMethod ) {
	var buffer = new Array();

	buffer.push("");									// leave empty line
	buffer.push(INDENT + theMethod.name);				// name of method

	if ( (typeof theMethod.info) == "string" ) {
		buffer.push(INDENT + INDENT + theMethod.info); // brief method info
	}

	// if the method has parameters, display them
	if ( (typeof theMethod.para) == "object" ) {
		buffer.push(INDENT + INDENT + "Parameters:");
		for (parameter = 0; parameter < theMethod.para.length; parameter++) {
			thePara = theMethod.para[parameter]; // short-cut
			// if the parameter may have more than one type, display them all
			if (typeof thePara[1] == "object") {
				var validTypes = "";	// initialize string
				for (validType = 0; validType < thePara[1].length; validType++) {
					validTypes += thePara[1][validType];
					if (validType != thePara[1].length-1) { 
						validTypes += ", ";	// add commas between valid type names
					}
				}
			} else {
				var validTypes = thePara[1];
			}
			// if the para is optional, it's name will disp. in square brackets
			if (thePara[2] == "Optional") {
				isOptOpen = "[";
				isOptClose = "]";
			} else {
				isOptOpen = "";
				isOptClose = "";
			}
			buffer.push( INDENT + INDENT + INDENT + isOptOpen + thePara[0] + isOptClose + " (" +
						 validTypes + ") : " + thePara[3] );
		}
	} else {
		buffer.push(INDENT + INDENT + "Parameters: None.");
	}

	// if method has return information, display it
	if ( (typeof theMethod.returns) == "string" ) {
		buffer.push(INDENT + INDENT + "Returns: " + theMethod.returns);
	}

	// if the method has error code information, display it
	if ( (typeof theMethod.errors) == "object") {
		buffer.push(INDENT + INDENT + "Error Codes & Messages:");
		for (errorCode = 0; errorCode < theMethod.errors.length; errorCode++) {
			theError = theMethod.errors[errorCode]; // short-cut
			buffer.push(INDENT + INDENT + INDENT + errorCode + ": " + theError);
		}
	}

	// if the method returns warning messages, display them
	if ( (typeof theMethod.warnings) == "object") {
		buffer.push(INDENT + INDENT + "Warning Codes & Messages:");
		for (warningCode = 0; warningCode < theMethod.warnings.length; warningCode++) {
			theWarning = theMethod.warnings[warningCode]; // short-cut
			buffer.push(INDENT + INDENT + INDENT + warningCode + ": " + theWarning);
		}
	}

	// if the method has a long descripion, display it
	if ( (typeof theMethod.longInfo) == "string" ) {
		buffer.push(INDENT + INDENT + theMethod.longInfo);
	}

	return buffer;
}


/*
	Initialization Code 
*/

if (Object.moose != undefined) { delete Object.moose; }; // clean up if being reloaded in browser

// create root Moose Module object (moose) ...
if (_global.moose == undefined) {
	_global.moose = new MooseModule("moose", 0.1, "Root Moose object");
}

// ... and an object to contain all global variables
if (moose.globals == undefined) {
	moose.globals = new Object();
}

/* 

	These need to created in the event and error modules, respectively
	
// Create the error information object
if (Object.moose.globals.error == undefined) {
	Object.moose.globals.error = new Object();
}

*/

_global.globals = moose.globals;	// short-cut to moose global variable namespace

// used to manage the depths of duplicated movieClips
globals.lastDepth = 1000;			

moose.getLastDepth = function() {
	return this.globals.lastDepth;
}
moose.getLastDepth.info = "Returns the depth of the last movieClip reported as attached to the stage with setLastDepth()";
moose.getLastDepth.type = "Public";


moose.setLastDepth = function(theLastDepth) {
	this.globals.lastDepth = theLastDepth;
	return this.globals.lastDepth;
}
moose.setLastDepth.info = "Sets the global variable that stores the depth of the last movieClip programmatically attached to the stage.";
moose.setLastDepth.para = [ 
	["theLastDepth", "number", "Required", "The depth of the last movieClip attached to the stage."]
];
moose.setLastDepth.type = "Public";


moose.incrementLastDepth = function() {
	return ++this.globals.lastDepth;
}
moose.incrementLastDepth.info = "Increments by one the global variable that stores the depth of the last movieClip added to the stage.";
moose.incrementLastDepth.type = "Public.";

