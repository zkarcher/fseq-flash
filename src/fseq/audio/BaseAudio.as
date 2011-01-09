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

public class BaseAudio extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	public static const LERP_SAMPLES :Number = 10;	// Smoothly transition between pitch/width/etc changes
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function BaseAudio() {
		super();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	protected var _freqInc :Number = 0;	// Every sample, increment the freqPhase by this amount
	protected var _amp :Number = 0;
	protected var _width :Number = 1;	// 0: no formant shaping. 2: extreme formant shaping, sounds like a pulse train.
	
	// Tweening
	protected var _tween :Number = 0;	// Range is 1..0; 1:tween begins, 0:tween has ended.
	protected var _oldFreqInc :Number = 0;
	protected var _newFreqInc :Number = 0;
	protected var _oldAmp :Number = 0;
	protected var _newAmp :Number = 0;
	protected var _oldWidth :Number = 0;
	protected var _newWidth :Number = 0;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function playFrame( frame:OperatorFrame, inWidth:Number, immediately:Boolean=false ) :void {
		// inc (_freqInc) will be added to _freqPhase every sample. This drives the oscillator.
		var inc:Number = frame.freq * ((2*Math.PI) / AudioPlayer.SAMPLE_RATE);
		
		if( immediately ) {
			_tween = 0;
			_freqInc = _newFreqInc = inc;
			_amp = _newAmp = frame.amp;
			_width = _newWidth = inWidth;

		} else {
			// Set the new parameters, and prepare to tween to the new parameters as we generate new samples.
			_tween = 1;	// Start a tween from the _old values to the _new ones.

			_oldFreqInc = _newFreqInc;
			_newFreqInc = inc;
			
			_oldAmp = _newAmp;
			_newAmp = frame.amp;

			_oldWidth = _newWidth;
			_newWidth = inWidth;
		}
	}
	
	// The pitchPhase is the same for all BaseAudio objects that are playing concurrently.
	public function getSample( pitchPhase:Number, resetSync:Boolean ) :Number {
		// Extend me!
		return 0;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	protected function updateTween() :void {
		// If _tween is 0, the tween is not active, so exit early.
		if( !_tween ) return;
		
		// The tween progresses...
		_tween = Math.max( 0, _tween - 1.0/LERP_SAMPLES );
		
		// Tween between the _old and _new values.
		_freqInc = Num.interpolate( _newFreqInc, _oldFreqInc, _tween );
		_amp = Num.interpolate( _newAmp, _oldAmp, _tween );
		_width = Num.interpolate( _newWidth, _oldWidth, _tween );
	}
}

}
