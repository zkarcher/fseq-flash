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
	public function SpectralAnalysisView( analysis:SpectralAnalysis ) {
		var bData:BitmapData = new BitmapData( Const.FRAMES, Const.FFT_BINS, false, 0x0 );
		
		for( var i:int=0; i<Const.FRAMES; i++ ) {
			var frame:Vector.<Number> = analysis.frame(i);
			for( var j:int=0; j<frame.length; j++ ) {
				var color:uint = int( Math.min(1.0,frame[j])*255 ) << 8;	// green (max will be 0x00ff00)
				bData.setPixel( i, bData.height-(j+1), color );
			}
		}
		
		var bmp:Bitmap = new Bitmap( bData, PixelSnapping.ALWAYS, false );
		bmp.scaleX = Const.GRAPH_SCALE_X;
		addChild( bmp );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	
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

