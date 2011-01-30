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
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function FormantDetector( inSpectrum:SpectralAnalysis ) {
		_spectrum = inSpectrum;
		_voiced = new Vector.<Vector.<OperatorFrame>>();
		_unvoiced = new Vector.<Vector.<OperatorFrame>>();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _spectrum :SpectralAnalysis;
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
		var start:Date = new Date();
		
		var w:int, i:int, v:int;
		
		// Create a window function, we'll apply this to the spectral power & sum the result.
		var window:Vector.<Number> = new Vector.<Number>( Const.FORMANT_DETECT_BANDWIDTH, true );
		for( w=0; w<window.length; w++ ) {
			window[w] = Math.cos( (Number(w)/(Const.FORMANT_DETECT_BANDWIDTH+1)) * Math.PI*0.5 );	// Cosine window
		}
		
		// Each 
		
		var frame:Vector.<Number> = _spectrum.frame(_index);	// This is the spectral data
		var powers:Vector.<Number> = new Vector.<Number>( frame.length, true );	// The power of each formant will be stored here
		var avFreqs:Vector.<Number> = new Vector.<Number>( frame.length, true );	// average frequecy (center) of the potential formants
		
		// At each potential formant frequency, compute the power at that formant
		for( i=0; i<frame.length; i++ ) {
			var power:Number = 0;
			var freqSum:Number = 0;
			// Apply the windowing function
			for( w=1-window.length; w<window.length; w++ ) {
				var band:int = w+i;
				if( band < 0 || frame.length <= band ) continue;	// out of bounds

				var thisPower:Number = frame[band] * window[ Math.abs(w) ];
				power += thisPower;
				freqSum += _spectrum.freqs[band] * thisPower;
			}
			
			// We have computed the power and average center frequency for a formant at this frequency:
			powers[i] = power;
			avFreqs[i] = freqSum / power;
		}
		
		// Choosing formants: When a formant is chosen, disallow its neighbars to be picked.
		var okToPick:Vector.<Boolean> = new Vector.<Boolean>( powers.length, true );
		for( i=0; i<powers.length; i++ ) {
			okToPick[i] = true;
		}
		
		var bestIndexes:Vector.<int> = new Vector.<int>( Const.VOICED_OPS, true );
		
		// Get the eight loudest formants.
		for( v=0; v<Const.VOICED_OPS; v++ ) {
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
		var voicedFrames:Vector.<OperatorFrame> = new Vector.<OperatorFrame>( Const.VOICED_OPS, true );
		var unvoicedFrames:Vector.<OperatorFrame> = new Vector.<OperatorFrame>( Const.UNVOICED_OPS, true );
		for( v=0; v<Const.VOICED_OPS; v++ ) {
			var idx:int = bestIndexes[v];
			voicedFrames[v] = new OperatorFrame( powers[idx], avFreqs[idx] );
			unvoicedFrames[v] = new OperatorFrame( powers[idx]*0.25, avFreqs[idx] );	// TODO: Compute the real power
		}
		
		_voiced.push( voicedFrames );
		_unvoiced.push( unvoicedFrames );
		
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
	
}

}

