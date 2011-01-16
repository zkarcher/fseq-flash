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

		var color:uint = Const.color( _type, _id );		
		var i:int;
		
		switch( _type ) {
			case Const.VOICED:
				// Voiced operators are represented as a chain of circles, with dots at their centers
				_dotData = new BitmapData( 1, 1, false, Const.color( Const.VOICED_DOT ) );
				
				_circData = new Vector.<BitmapData>();
				for( i=0; i<MAX_CIRC_RADIUS-2; i++ ) {
					var bData:BitmapData = new BitmapData( MAX_CIRC_RADIUS*2-1, MAX_CIRC_RADIUS*2-1, true, 0x0 );
					var shp:Shape = new Shape();
					with( shp.graphics ) {
						beginFill( color, 1.0 );
						drawCircle( MAX_CIRC_RADIUS-0.5, MAX_CIRC_RADIUS-0.5, i+1.5 );
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
				break;

			case Const.UNVOICED:
				_patternData = new BitmapData( 8, 1, true, 0x0 );
				for( var p:int=0; p<8; p++ ) {
					var color32:uint = color | (int(p*(255/8)) << 24);
					_patternData.setPixel32( p, 0, color32 );
				}
				break;
		}
		
		blendMode = BlendMode.LAYER;
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;	// VOICED or UNVOICED, or maybe PITCH
	private var _id :int;
	private var _rect :Rectangle;
	private var _isEditable :Boolean;
	
	// DRAWING: Voiced:
	private var _circData :Vector.<BitmapData>;
	private var _circs :Vector.<Bitmap>;
	private var _dotData :BitmapData;
	private var _dots :Vector.<Bitmap>;
	
	// DRAWING: Unvoiced
	private var _patternData :BitmapData;
	private var _shape :Shape;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get type() :String { return _type; }
	public function get id() :int { return _id; }
	
	public function get isEditable() :Boolean { return _isEditable; }
	public function set isEditable( b:Boolean ) :void {
		_isEditable = b;
		alpha = b ? 1.0 : 0.4;
	}
	
	// Hilite when the mouse hovers near this OperatorView, for example
	public function set hilite( b:Boolean ) :void {
		if( b ) {
			var dark:Number = Const.INACTIVE_BRIGHTNESS;
			this.transform.colorTransform = new ColorTransform( dark,dark,dark,1, 0x7f,0x7f,0x7f,0 );
		} else {
			this.transform.colorTransform = new ColorTransform();
		}
	}
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function operatorInSequence( fseq:FormantSequence ) :Operator {
		switch( _type ) {
			case Const.VOICED:	return fseq.voiced(_id);
			case Const.UNVOICED: return fseq.unvoiced(_id);
		}
		return null;
	}
	
	public function yAtFrame( fseq:FormantSequence, f:int ) :Number {
		var operator:Operator = operatorInSequence( fseq );
		return _rect.height * (1 - operator.frame(f).freq * (1/7000.0));
	}
	
	public function redraw( fseq:FormantSequence, leftFrame:int, rightFrame:int ) :void {
		var f:int;
		var atY:Number;
		var operator:Operator;
		
		switch( _type ) {
			case Const.VOICED:
				operator = fseq.voiced(_id);

				for( f=leftFrame; f<=rightFrame; f++ ) {
					atY = yAtFrame(fseq, f);

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
				break;
				
			case Const.UNVOICED:
				/*
				operator = fseq.unvoiced(_id);

				if( _shape && _shape.parent ) _shape.parent.removeChild( _shape );
				
				_shape = new Shape();
				_shape.graphics.beginBitmapFill( _patternData, null, true );
				for( f=0; f<Const.FRAMES; f++ ) {
					atY = yAtFrame(fseq, f);
					_shape.graphics.lineTo( f*Const.GRAPH_SCALE_X, atY - operator.frame(f).amp * MAX_CIRC_RADIUS );
				}
				for( f=Const.FRAMES-1; f>=0; f-- ) {
					atY = yAtFrame(fseq, f);
					_shape.graphics.lineTo( f*Const.GRAPH_SCALE_X, atY + operator.frame(f).amp * MAX_CIRC_RADIUS );
				}
				_shape.graphics.endFill();
				addChild( _shape );
				*/
				break;
			
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

