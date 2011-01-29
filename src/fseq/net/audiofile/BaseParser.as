package fseq.net.audiofile {

/**
 *	Class description.
 *
 *	@langversion ActionScript 3.0
 *	@playerversion Flash 10.0
 *
 *	@author Zach Archer
 *	@since  20110108
 */

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.view.*;

public class BaseParser extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function BaseParser() {
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	protected var _ba :ByteArray;
	protected var _isParsed :Boolean = false;
	protected var _error :String;	// only set if parse failed
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get isParsed() :Boolean { return _isParsed; }
	public function get error() :String { return _error; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	// Return true if parse succeeds, false otherwise
	public function parse( ba:ByteArray ) :Boolean {
		// Extend me!
		return false;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

