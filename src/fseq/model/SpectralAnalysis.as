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
import gerrybeauregard.FFT;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.net.audiofile.*;
import fseq.view.*;

public class SpectralAnalysis extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function SpectralAnalysis( parser:BaseParser ) {
	 	var f:int, i:int;
		
		// From the audio file parser, create a spectral analysis
		_frames = new Vector.<Vector.<Number>>();
		var maxPower:Number = 0;
		
		for( f=0; f<Const.FRAMES; f++ ) {
			var progress:Number = Number(f) / Const.FRAMES;	// 0..1
			
			var real:Vector.<Number> = parser.getMonoSamplesAtProgress( progress, Const.FFT_BINS );
			// Windowing function
			for( i=0; i<Const.FFT_BINS; i++ ) {
				var hann:Number = (1 - Math.cos( (Number(i)/Const.FFT_BINS)*2*Math.PI )) * 0.5;
				//real[i] *= hann;
				var hamming:Number = hann*0.92 + 0.08;
				real[i] *= hamming;
			}
			
			var imag:Vector.<Number> = new Vector.<Number>( Const.FFT_BINS, true );
			for( i=0; i<Const.FFT_BINS; i++ ) {
				imag[i] = 0;
			}
			
			var fft:FFT = new FFT();
			fft.init( Num.lg(Const.FFT_BINS) );
			fft.run( real, imag, FFT.FORWARD );
			
			var frame:Vector.<Number> = new Vector.<Number>( Const.SPECTRAL_BANDS, true );
			for( i=0; i<Const.SPECTRAL_BANDS; i++ ) {
				// Ignore the first & center FFT result bands, they're fq=0 and fq=NyquistFreq.
				var re:Number = real[i+1];
				var im:Number = imag[i+1];
				
				var power:Number = Math.sqrt( re*re + im*im );
				frame[i] = power;

				maxPower = Math.max( maxPower, power );
			}
			
			_frames[f] = frame;
		}
		
		// Normalize all frames to maxPower
		var powerMult:Number = 1/maxPower;
		for( f=0; f<Const.FRAMES; f++ ) {
			for( i=0; i<Const.SPECTRAL_BANDS; i++ ) {
				_frames[f][i] *= powerMult;
			}
		}
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _frames :Vector.<Vector.<Number>>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function frame( index:int ) :Vector.<Number> {
		return _frames[index];
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

