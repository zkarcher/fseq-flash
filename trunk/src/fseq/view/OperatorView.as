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

public class OperatorView extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	private static const MAX_CIRC_RADIUS :Number = 8;
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function OperatorView( type:String, id:int, rect:Rectangle ) {
		_type = type;
		_id = id;
		_rect = rect;
		
		var i:int;
		
		switch( _type ) {
			case Const.VOICED:
			case Const.UNVOICED:	// <-- TODO: this is temporary
				// Voiced operators are represented as a chain of circles, with dots at their centers
				_dotData = new BitmapData( 1, 1, false, 0xffffff );
				
				_circData = new Vector.<BitmapData>();
				var color:uint = Const.color( _type, _id );
				for( i=0; i<MAX_CIRC_RADIUS-2; i++ ) {
					var bData:BitmapData = new BitmapData( MAX_CIRC_RADIUS*2-1, MAX_CIRC_RADIUS*2-1, true, 0x0 );
					var shp:Shape = new Shape();
					with( shp.graphics ) {
						beginFill( color, 1.0 );
						drawCircle( MAX_CIRC_RADIUS-1, MAX_CIRC_RADIUS-1, i+2 );
						endFill();
					}
					bData.draw( shp );
					_circData.push( bData );
				}
				
				// Now that our bitmap data(s) are ready, create all the Bitmaps for the operator
				_circs = new Vector.<Bitmap>( Const.FRAMES, true );
				_dots = new Vector.<Bitmap>( Const.FRAMES, true );
				for( i=0; i<Const.FRAMES; i++ ) {
					_circs[i] = new Bitmap( _circData[2], PixelSnapping.ALWAYS, false );
					_circs[i].x = i*Const.GRAPH_SCALE_X - (MAX_CIRC_RADIUS-1);
					addChildAt( _circs[i], 0 );
					_dots[i] = new Bitmap( _dotData, PixelSnapping.ALWAYS, false );
					_dots[i].x = i*Const.GRAPH_SCALE_X;
					addChild( _dots[i] );	// all black dots are placed on top of the circles
				}
				/*
			case Const.UNVOICED:
				_bData = new BitmapData( 1, 1, false, Const.color(_type,_id) );
				break;
				*/
		}
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;	// VOICED or UNVOICED, or maybe PITCH
	private var _id :int;
	private var _rect :Rectangle;
	
	// Voiced:
	private var _circData :Vector.<BitmapData>;
	private var _circs :Vector.<Bitmap>;
	private var _dotData :BitmapData;
	private var _dots :Vector.<Bitmap>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function redraw( fseq:FormantSequence ) :void {
		var operator:Operator;
		switch( _type ) {
			case Const.VOICED:		operator = fseq.voiced(_id); break;
			case Const.UNVOICED:	operator = fseq.unvoiced(_id); break;
		}
		
		if( _type == Const.UNVOICED ) return;
		
		for( var f:int=0; f<Const.FRAMES; f++ ) {
			var atY:Number = _rect.height * (1 - operator.frame(f).freq * (1/7000.0));
			
			_dots[f].y = atY;
			_circs[f].y = atY - (MAX_CIRC_RADIUS-1);
			
			// Change the circle size, if necessary.
			// Louder frames have larger circles.
			var amp:Number = operator.frame(f).amp;
			var ampCompare :Number = 0.5;
			var circId:int = _circData.length-1;
			while( circId > 0 && amp < ampCompare ) {
				ampCompare *= 0.5;
				circId--;
			}
			_circs[f].bitmapData = _circData[circId];
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

