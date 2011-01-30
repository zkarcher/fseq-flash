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
	 	var i:int;
		
		// From the audio file parser, create a spectral analysis
		_frames = new Vector.<Vector.<Number>>();
		
		for( var f:int=0; f<Const.FRAMES; f++ ) {
			var progress:Number = Number(f) / Const.FRAMES;	// 0..1
			
			var real:Vector.<Number> = parser.getMonoSamplesAtProgress( progress, Const.FFT_BINS );
			// Windowing function
			// A Hann window is probably fine
			for( i=0; i<Const.FFT_BINS; i++ ) {
				real[i] *= (1 - Math.cos( (Number(i)/Const.FFT_BINS)*2*Math.PI )) * 0.5;
			}
			
			var imag:Vector.<Number> = new Vector.<Number>( Const.FFT_BINS, true );
			for( i=0; i<Const.FFT_BINS; i++ ) {
				imag[i] = 0;
			}
			
			var fft:FFT = new FFT();
			fft.init( Num.lg(Const.FFT_BINS) );
			fft.run( real, imag, FFT.FORWARD );
			
			var frame:Vector.<Number> = new Vector.<Number>( Const.FFT_BINS, true );
			for( i=0; i<Const.FFT_BINS; i++ ) {
				frame[i] = Math.sqrt( real[i]*real[i] + imag[i]+imag[i] );
			}
			
			_frames[f] = frame;
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

