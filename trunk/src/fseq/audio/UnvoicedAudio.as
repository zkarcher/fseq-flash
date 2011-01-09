package fseq.audio {

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
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.audio.*;

public class UnvoicedAudio extends BaseAudio
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function UnvoicedAudio() {
		super();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	/*
	public override function playFrame( frame:OperatorFrame, width:Number, immediately:Boolean=false ) :void {
	}
	*/

	// The pitchPhase is the same for all BaseAudio objects that are playing concurrently.
	public override function getSample( pitchPhase:Number, resetSync:Boolean ) :Number {
		updateTween();
		
		// Extend me!
		return 0;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

