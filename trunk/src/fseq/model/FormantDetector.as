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
import flash.filters.*;
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
	public function FormantDetector( inSpectrum:SpectralAnalysis, inPitch:Operator, inSmoothness:Number ) {
		_spectrum = inSpectrum;
		_pitch = inPitch;

		_voiced = new Vector.<Vector.<OperatorFrame>>();
		_unvoiced = new Vector.<Vector.<OperatorFrame>>();
		
		// Instead of manipulating fields of Numbers every frame, just export the spectrum into BitmapData,
		// and apply a blur operation. w00t.
		_spectrumData = _spectrum.asBitmapData();
		
		var blurWidth:Number = inSmoothness;
		var blurHeight:Number = Const.FORMANT_DETECT_BANDWIDTH;
		var blurFilter:BlurFilter = new BlurFilter( blurWidth, blurHeight, BitmapFilterQuality.HIGH );
		_spectrumData.applyFilter( _spectrumData, _spectrumData.rect, new Point(0,0), blurFilter );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _spectrum :SpectralAnalysis;
	private var _spectrumData :BitmapData;
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
		var VURatios:Vector.<Number> = new Vector.<Number>( frame.length, true );
		
		// For every row, (at each potential formant frequency,) compute the power at that formant
		for( i=0; i<frame.length; i++ ) {
			//var pitch:Number = _pitch.frame(_index).freq;
			
			/*
			var VPower:Number = 0;
			var UPower:Number = 0;
			var VFreqSum:Number = 0;
			var UFreqSum:Number = 0;
			*/
			
			/*
			// OLDER METHOD: Apply a window function to the Numbers inside the frame.
			var unwindowed:Vector.<Number> = new Vector.<Number>( window.length*2-1, true );
			var windowed:Vector.<Number> = new Vector.<Number>( window.length*2-1, true );	// windowed spectrum
			var power:Number = 0;
			var freqSum:Number = 0;
			
			for( w=1-window.length; w<window.length; w++ ) {
				var band:int = w+i;
				
				var setIndex:int = w+window.length-1;
				
				// If the window is looking outside of the band, then its values at those coordinates should be 0
				if( band < 0 || frame.length <= band ) {
					unwindowed[setIndex] = 0;
					windowed[setIndex] = 0;
					continue;
				} else {
					var bandFreq:Number = _spectrum.freqs[band];
					unwindowed[setIndex] = frame[band];
					var thisPower:Number = frame[band] * window[Math.abs(w)];
					windowed[setIndex] = thisPower;
					power += thisPower;
					freqSum += bandFreq * thisPower;
				}
			}
			
			// Pitched formants should have higher band energy / total energy
			var maxEnergyRatio:Number = 0;
			for( w=0; w<windowed.length; w++ ) {
				maxEnergyRatio = Math.max( maxEnergyRatio, unwindowed[w] / power );
			}

			// Seems to vary between about 0.15 and 0.30 usually:
			//trace("My maxEnergyRatio is", maxEnergyRatio);

			// We have computed the power and average center frequency for a formant at this frequency:
			VFreqs[i] = UFreqs[i] = freqSum / power;
			*/
			
			// NEWER METHOD: We have already exported the spectral data as a BitmapData, and applied a blur filter.
			// Just sample the pixel at that location.
			var power:Number = Number( _spectrumData.getPixel( _index, i )) * (1.0/255);
			// This number is logarithmic, so shift it back to linear scale
			power = Math.pow( 2, power )-1;
			power = Math.max( 0, power );	// sanity check; never below 0
			VFreqs[i] = UFreqs[i] = _spectrum.freqs[i];
			
			if( false ) {
				// All voiced energy
				VPowers[i] = power;// / VFreqs[i];
				UPowers[i] = 0;
			} else {
				// Based on maxEnergyRatio, try to guess whether this formant frame is voiced or unvoiced
				//var vuRatio:Number = Num.clamp( (maxEnergyRatio-Const.UNVOICED_ENERGY_RATIO) / (Const.VOICED_ENERGY_RATIO-Const.UNVOICED_ENERGY_RATIO), 0.0, 1.0 );	// 0..1
				var vuRatio:Number = 0.9;
				VURatios[i] = vuRatio;
				VPowers[i] = power * vuRatio;
				UPowers[i] = power * (1-vuRatio);
			}
			
			/*
			if( LOWPASS ) {
				avFreqs[i] = _spectrum.freqs[i];	// Boring, no frequency variations
			} else {
				avFreqs[i] = freqSum / power;
			}
			*/
		}
		
		pickAndStoreFormants( Const.VOICED_OPS, VPowers, VFreqs, UPowers, UFreqs, _spectrum.freqs, VURatios );
		
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
	private function pickAndStoreFormants( count:int, VPowers:Vector.<Number>, VFreqs:Vector.<Number>, UPowers:Vector.<Number>, UFreqs:Vector.<Number>, bandFreqs:Vector.<Number>, vuRatios:Vector.<Number> ) :void {
		var v:int, i:int;
		
		// Choosing formants: When a formant is chosen, disallow its neighbars to be picked.
		var okToPick:Vector.<Boolean> = new Vector.<Boolean>( VPowers.length, true );
		for( i=0; i<VPowers.length; i++ ) {
			okToPick[i] = bandFreqs[i] < Const.IMPORT_HIGHEST_FORMANT_FREQ;
		}
		
		// Populate bestIndexes with the index numbers of the chosen (strongest) formants
		var bestIndexes:Vector.<int> = new Vector.<int>( count, true );
		for( v=0; v<count; v++ ) {
			var bestIndex:int = -1;
			for( i=0; i<VPowers.length; i++ ) {
				if( !okToPick[i] ) continue;
				
				// Does this formant region have more power?
				if( bestIndex==-1 || VPowers[i] > VPowers[bestIndex] ) {
					bestIndex = i;
				}
			}
			
			if( bestIndex==-1 ) bestIndex = VPowers.length-1;	// D'oh. Probably the entire frequency band is occupied now.
			
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
		var VOps :Vector.<OperatorFrame> = new Vector.<OperatorFrame>( Const.VOICED_OPS, true );
		var UOps :Vector.<OperatorFrame> = new Vector.<OperatorFrame>( Const.UNVOICED_OPS, true );
		var ratios:Vector.<Number> = new Vector.<Number>( Const.VOICED_OPS, true );
		for( v=0; v<Const.VOICED_OPS; v++ ) {
			var idx:int = bestIndexes[v];
			// Why are the highest formants so much louder?? Hmmm
			VOps[v] = new OperatorFrame( VPowers[idx] /* / VFreqs[idx]*/, VFreqs[idx] );
			UOps[v] = new OperatorFrame( UPowers[idx] /* / UFreqs[idx]*/, UFreqs[idx] );
			ratios[v] = vuRatios[idx];
		}
		//trace("Chose vu ratios:", ratios);
		
		_voiced.push( VOps );
		_unvoiced.push( UOps );
	}
	
}

}

