package fseq.view {

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
import fseq.view.*;

public class SpectralAnalysisView extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function SpectralAnalysisView( analysis:SpectralAnalysis, rect:Rectangle ) {
		var i:int;
		
		_bData = new BitmapData( Const.FRAMES, rect.height, false, 0x0 );
		_bmp = new Bitmap( _bData, PixelSnapping.ALWAYS, false );
		with( _bmp ) {
			x = rect.x;
			y = rect.y;
			width = rect.width;
			height = rect.height;
		}
		addChild( _bmp );
		
		var colorInts:Array = [0x0, 0x6600ff, 0xff00ff, 0xff0000, 0xff8800, 0xffff00, 0xffff88, 0xffffff];
		var colorChoices :int = colorInts.length;
		var color:int;
		var rgbs:Array = [];
		for each( color in colorInts ) {
			rgbs.push( ColorUtil.rgb( color ) );
		}
		// Optimization: Clone the final (brightest) color, this will prevent rounding errors when the incoming power is 1.0
		rgbs.push( ColorUtil.rgb( colorInts[colorInts.length-1] ));
		rgbs.push( ColorUtil.rgb( colorInts[colorInts.length-1] )); // And again in case 6.06 (or whatever) sneaks through

		// Pre-compute the yToFreqs
		var yToFreqs:Vector.<Number> = new Vector.<Number>( Const.SPECTRAL_BANDS, true );
		for( i=0; i<Const.SPECTRAL_BANDS; i++ ) {
			yToFreqs[i] = GraphView.yToFreq( rect.height, i );
		}

		for( var f:int=0; f<Const.FRAMES; f++ ) {
			var frame:Vector.<Number> = analysis.frame(f);
			for( i=0; i<Const.SPECTRAL_BANDS; i++ ) {
				// Which spectral analysis band are we looking at?
				var band:Number = (yToFreqs[i] / (Const.SAMPLE_RATE/2)) * (Const.FFT_BINS/2);

				var loPower = (band<1.0) ? 0 : frame[Math.floor(band-1)];	// SpectralAnalysis drops the first FFT bin (fq=0)
				var hiPower = (Const.SPECTRAL_BANDS<=band) ? 0 : frame[Math.ceil(Math.max(0,band-1))];
				
				var power:Number = Num.interpolate( loPower, hiPower, band - Math.floor(band) );
				power *= colorChoices;
				
				var lo:Object = rgbs[ Math.floor(power) ];
				var hi:Object = rgbs[ Math.ceil(power) ];
				var progress:Number = power - Math.floor(power);	// decimal portion of the power
				
				if( !lo || !hi ) trace("debug:", power, progress, lo, hi );
				
				color = (int(Num.interpolate( lo.r, hi.r, progress )) << 16) |
						(int(Num.interpolate( lo.g, hi.g, progress )) << 8) |
						int(Num.interpolate( lo.b, hi.b, progress ));
				_bData.setPixel( f, i, color );
			}
		}

	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _bData:BitmapData;
	private var _bmp :Bitmap;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

