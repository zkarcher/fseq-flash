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

public class FormantDetector extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	//private static const LOWPASS :Boolean = false;
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function FormantDetector( inSpectrum:SpectralAnalysis, inPitch:Operator ) {
		_spectrum = inSpectrum;
		_pitch = inPitch;

		_voiced = new Vector.<Vector.<OperatorFrame>>();
		_unvoiced = new Vector.<Vector.<OperatorFrame>>();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _spectrum :SpectralAnalysis;
	private var _pitch :Operator;
	private var _index :int = 0;
	private var _voiced :Vector.<Vector.<OperatorFrame>>;		// _voiced[frame][opIndex]
	private var _unvoiced :Vector.<Vector.<OperatorFrame>>;	// _unvoiced[frame][opIndex]
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get isComplete() :Boolean { return _index >= Const.FRAMES; }
	public function get index() :int { return _index; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function voicedFrame( frame:int, opIndex:int ) :OperatorFrame {
		return _voiced[frame][opIndex];
	}
	public function unvoicedFrame( frame:int, opIndex:int ) :OperatorFrame {
		return _unvoiced[frame][opIndex];
	}
	
	// Using time domain pitch detection (autocorrelation) for now.
	// Returns the amount of time required for this detection step.
	public function detectNext() :Number {
		if( isComplete ) return 0;
		
		var start:Date = new Date();
		
		var w:int, i:int;
		
		// Create a window function, we'll apply this to the spectral power & sum the result.
		var window:Vector.<Number> = new Vector.<Number>( Const.FORMANT_DETECT_BANDWIDTH, true );
		for( w=0; w<window.length; w++ ) {
			window[w] = Math.cos( (Number(w)/(Const.FORMANT_DETECT_BANDWIDTH+1)) * Math.PI*0.5 );	// Cosine window
		}
		
		var frame:Vector.<Number> = _spectrum.frame(_index);	// This is the spectral data
		// The power of each formant will be stored here. V==voiced, U==unvoiced
		var VPowers:Vector.<Number> = new Vector.<Number>( frame.length, true );
		var UPowers:Vector.<Number> = new Vector.<Number>( frame.length, true );
		var VFreqs:Vector.<Number> = new Vector.<Number>( frame.length, true );	// average frequecy (center) of the potential formants
		var UFreqs:Vector.<Number> = new Vector.<Number>( frame.length, true );
		
		// At each potential formant frequency, compute the power at that formant
		for( i=0; i<frame.length; i++ ) {
			var pitch:Number = _pitch.frame(_index).freq;

			var VPower:Number = 0;
			var UPower:Number = 0;
			var VFreqSum:Number = 0;
			var UFreqSum:Number = 0;
			// Apply the windowing function
			for( w=1-window.length; w<window.length; w++ ) {
				var band:int = w+i;
				if( band < 0 || frame.length <= band ) continue;	// out of bounds
				
				var bandFreq:Number = _spectrum.freqs[band];
				
				var thisPower:Number = frame[band] * window[ Math.abs(w) ];
				
				// Split this into voiced & unvoiced energy, depending on how in tune this freq is with our base pitch
				var harmonic:Number = bandFreq / pitch;
				// Wrap between 0..1, fold over towards 0
				var h:Number = Num.wrap( harmonic, 1.0 );
				if( h > 0.5 ) h = 1-h;	// fold over towards 0

				var VPercent:Number = 0;	// Apply this much of thisPower to VPower, the rest to UPower
				if( h < Const.PITCHED_REGION_OF_OVERTONE ) {
					VPercent = (Math.cos( (h/Const.PITCHED_REGION_OF_OVERTONE)*Math.PI ) + 1) / 2;
				}
				
				// Voiced formant results are much better without VPercent applied.
				VPower += thisPower;// * VPercent;
				UPower += thisPower * (1-VPercent);
				VFreqSum += bandFreq * thisPower;//(thisPower * VPercent);
				UFreqSum += bandFreq * (thisPower * (1-VPercent));
				
				/*
				if( LOWPASS ) {
					power += thisPower / _spectrum.freqs[band];	// compensate for uneven energy across the spectrum
				} else {
					power += thisPower;
					freqSum += _spectrum.freqs[band] * thisPower;
				}
				*/
			}
			
			// We have computed the power and average center frequency for a formant at this frequency:
			VPowers[i] = VPower;
			// Unvoiced (noise) power will be louder than pitched power, so turn it down!
			UPowers[i] = UPower;// * Const.PITCHED_REGION_OF_OVERTONE*2;
			
			VFreqs[i] = (VPower > 0) ? (VFreqSum / VPower) : pitch;
			UFreqs[i] = (UPower > 0) ? (UFreqSum / UPower) : pitch;
			
			/*
			if( LOWPASS ) {
				avFreqs[i] = _spectrum.freqs[i];	// Boring, no frequency variations
			} else {
				avFreqs[i] = freqSum / power;
			}
			*/
		}
		
		_voiced.push( pickFormants( Const.VOICED_OPS, VPowers, VFreqs ) );
		_unvoiced.push( pickFormants( Const.UNVOICED_OPS, UPowers, UFreqs ) );
		
		_index++;
		
		var end:Date = new Date();
		return (end.time - start.time) * (1.0/1000);	// Convert milliseconds to seconds
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	private function pickFormants( count:int, powers:Vector.<Number>, freqs:Vector.<Number> ) :Vector.<OperatorFrame> {
		var v:int, i:int;
		
		// Choosing formants: When a formant is chosen, disallow its neighbars to be picked.
		var okToPick:Vector.<Boolean> = new Vector.<Boolean>( powers.length, true );
		for( i=0; i<powers.length; i++ ) {
			okToPick[i] = true;
		}
		
		// Populate bestIndexes with the index numbers of the chosen (strongest) formants
		var bestIndexes:Vector.<int> = new Vector.<int>( count, true );
		for( v=0; v<count; v++ ) {
			var bestIndex:int = -1;
			for( i=0; i<powers.length; i++ ) {
				if( !okToPick[i] ) continue;
				
				// Does this formant region have more power?
				if( bestIndex==-1 || powers[i] > powers[bestIndex] ) {
					bestIndex = i;
				}
			}
			
			bestIndexes[v] = bestIndex;
			
			// Neighboring formants may not be chosen!
			var disallow:int = Const.FORMANT_DETECT_DISALLOW_NEIGHBORS;
			for( i=-disallow; i<=disallow; i++ ) {
				var disIndex:int = bestIndex + i;
				if( disIndex < 0 || okToPick.length <= disIndex ) continue;	// out of bounds
				okToPick[disIndex] = false;
			}
		}
		
		// Sort the indexes
		bestIndexes = bestIndexes.sort( function(a:int,b:int):Number { return a-b; } );
		
		// Create operator frames
		var out:Vector.<OperatorFrame> = new Vector.<OperatorFrame>( count, true );
		for( v=0; v<Const.VOICED_OPS; v++ ) {
			var idx:int = bestIndexes[v];
			// Why are the highest formants so much louder?? Hmmm
			out[v] = new OperatorFrame( powers[idx] / freqs[idx], freqs[idx] );
		}
		return out;
	}
	
}

}

