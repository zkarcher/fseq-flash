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
	// The pitchPhase is the same for all BaseAudio objects that are playing concurrently.
	public override function addSamples( buffer:Vector.<Number>, pitchPhases:Vector.<Number>, resetSyncs:Vector.<Boolean>, setFrameIds:Vector.<int>, operator:Operator ) :void {
		
		for( var i:int=0; i<Const.BUFFER_SIZE; i++ ) {
			// Time for a new frame?
			if( setFrameIds[i] >= 0 ) {
				playFrame( operator.frame( setFrameIds[i] ));
			}
			
			updateTween();
			
			// Reset the freq oscillator so a coherent pitched formant is created
			if( resetSyncs[i] ) {
				_freqPhase = 0;
			}
			
			// Create the sound
			_freqPhase += _freqInc;	// Advance the formant frequency ascillator
			buffer[i] += (Math.cos( pitchPhases[i] ) - 1) * Math.sin(_freqPhase) * 0.5 * _amp;
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

