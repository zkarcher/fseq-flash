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
	private var _freqPhase :Number = 0;
	
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
	public override function addSamples( buffer:Vector.<Number>, pitchPhases:Vector.<Number>, resetSyncs:Vector.<Boolean>, setFrameIds:Vector.<int>, operator:Operator ) :void {
		updateTween();
		
		for( var i:int=0; i<Const.BUFFER_SIZE; i++ ) {
			// Time for a new frame?
			if( setFrameIds[i] >= 0 ) {
				playFrame( operator.frame( setFrameIds[i] ));
			}
			
			updateTween();
			
			// Create the sound
			_freqPhase += _freqInc + ((Math.random()*2)-1) * 0.2;
			buffer[i] += Math.sin( _freqPhase ) * _amp * 0.75;
		}
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

