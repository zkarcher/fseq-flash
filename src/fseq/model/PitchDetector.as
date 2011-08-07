package fseq.model {

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
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.net.audiofile.*;
import fseq.view.*;

public class PitchDetector extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	private static const DEBUG :Boolean = false;
	private static const QUICK_COMB_INTERVAL :int = 20;
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function PitchDetector( inParser:BaseParser, inLowerLimit:Number, inUpperLimit:Number ) {
		_pitches = new Vector.<Number>( Const.FRAMES, true );
		_parser = inParser;
		_lowerLimit = inLowerLimit;
		_upperLimit = inUpperLimit;
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _parser :BaseParser;
	
	private var _pitches :Vector.<Number>;
	private var _lowerLimit :Number;
	private var _upperLimit :Number;
	private var _index :int = 0;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get isComplete() :Boolean { return _index >= Const.FRAMES; }
	public function get index() :int { return _index; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function pitchAt( frame:int ) :Number {
		return _pitches[frame];
	}
	
	// Using time domain pitch detection (autocorrelation) for now.
	// Returns the amount of time required for this detection step.
	public function detectNext() :Number {
		if( isComplete ) return 0;
		
		var start:Date = new Date();
		
		var windowWidth:int = Math.round( Const.SAMPLE_RATE / _lowerLimit );
		var samps:Vector.<Number> = _parser.getMonoSamplesAtProgress( Number(_index)/Const.FRAMES, windowWidth*2 );		
		
		var bestComb:int = 0;
		var bestPower:Number = -999999;
		
		// Start by testing the lowest allowed pitch, work to the highest
		var combLow:int = windowWidth;
		var combHigh:int = Math.ceil( Const.SAMPLE_RATE / _upperLimit );
		var comb:int, power:Number, w:int;
		for( comb=combLow; comb>=combHigh; comb-=QUICK_COMB_INTERVAL ) {
			power = 0;
			for( w=0; w<comb; w++ ) {
				power += samps[w] * samps[w+comb];
			}
			
			// Try to compensate for octave errors: Multiply by the comb width
			//power *= comb;	// NO, we're already summing less samples for narrower combs
			
			if( power > bestPower ) {
				bestPower = power;
				bestComb = comb;
			}
		}
		
		// Now we've isolated the best comb response, +/- QUICK_COMB_INTERVAL/2.
		// Get more granular, and find the very best response.
		var oldBest:int = bestComb;
		combLow = Math.min( windowWidth, oldBest+QUICK_COMB_INTERVAL/2 );
		combHigh = Math.max( Math.ceil( Const.SAMPLE_RATE / _upperLimit ), oldBest-QUICK_COMB_INTERVAL/2 );
		for( comb=combLow; comb>=combHigh; comb-- ) {
			if( comb==oldBest ) continue;	// we already checked this one

			power = 0;
			for( w=0; w<comb; w++ ) {
				power += samps[w] * samps[w+comb];
			}
			
			if( power > bestPower ) {
				bestPower = power;
				bestComb = comb;
			}
		}
		
		_pitches[_index] = Const.SAMPLE_RATE / bestComb;
		//trace("Pitch:", _index, _pitches[_index]);
		
		_index++;
		
		var end:Date = new Date();
		return (end.time - start.time) * (1.0/1000);	// Convert milliseconds to seconds
	}
	
	public function skipRemaining() :void {
		for( var i:int=_index; i<Const.FRAMES; i++ ) {
			if( _index==0 ) {
				_pitches[i] = 110.0;
			} else {
				// Loop whatever pitches we've already detected
				_pitches[i] = _pitches[i%_index];
			}
		}
		
		_index = Const.FRAMES;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

