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
import fseq.model.*;

public class VoicedAudio extends BaseAudio
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function VoicedAudio() {
		super();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _freqPhase :Number = 0;	// One cycle is range: 0..2*Math.PI 
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public override function playFrame( frame:OperatorFrame, width:Number, immediately:Boolean=false ) :void {
		super.playFrame( frame, width, immediately );
	}

	// The pitchPhase is the same for all BaseAudio objects that are playing concurrently.
	public override function getSample( pitchPhase:Number, resetSync:Boolean ) :Number {
		updateTween();
		
		// Reset the freq oscillator so a coherent pitched formant is created
		if( resetSync ) {
			_freqPhase = 0;
		}
		
		_freqPhase += _freqInc;
		return (Math.cos( pitchPhase ) - 1) * Math.sin(_freqPhase) * 0.5 * _amp;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

