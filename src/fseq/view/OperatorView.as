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
	private static const NOISE_WIDTH :int = 256;
	private static const NOISE_HEIGHT :int = 128;
	private static const MIN_NOISE_DISPLAY_HEIGHT :Number = 12;
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function OperatorView( type:String, id:int, rect:Rectangle ) {
		_type = type;
		_id = id;
		_rect = rect;

		var color:uint = Const.color( _type, _id );		
		var i:int;
		var bData:BitmapData;
		var shp:Shape;
		
		// All operators are represented as a chain of shapes, with dots at their centers
		_dotData = new BitmapData( 1, 1, false, Const.color( Const.VOICED_DOT ) );
		_dots = new Vector.<Bitmap>( Const.FRAMES, true );
		for( i=0; i<Const.FRAMES; i++ ) {
			_dots[i] = new Bitmap( _dotData, PixelSnapping.ALWAYS, false );
			_dots[i].x = i*Const.GRAPH_SCALE_X;
			addChild( _dots[i] );
		}		
		
		switch( _type ) {
			case Const.VOICED:				
				_circData = new Vector.<BitmapData>();
				for( i=0; i<MAX_CIRC_RADIUS-2; i++ ) {
					bData = new BitmapData( i*2+3, i*2+3, true, 0x0 );
					shp = new Shape();
					with( shp.graphics ) {
						beginFill( color, 1.0 );
						drawCircle( bData.width/2, bData.height/2, i+1.5 );
						endFill();
					}
					bData.draw( shp );
					_circData.push( bData );
				}
				
				// Now that our bitmap data(s) are ready, create all the Bitmaps for the operator
				_circs = new Vector.<Bitmap>( Const.FRAMES, true );
				for( i=0; i<Const.FRAMES; i++ ) {
					_circs[i] = new Bitmap( _circData[2], PixelSnapping.ALWAYS, false );
					_circs[i].x = i*Const.GRAPH_SCALE_X - (MAX_CIRC_RADIUS-1);
					addChildAt( _circs[i], 0 );
				}
				
				// The circles will overlap, so render as a single layer (looks better when dimmed)
				blendMode = BlendMode.LAYER;
				
				break;

			case Const.UNVOICED:
				if( !_noise ) {
					_noise = new BitmapData( NOISE_WIDTH, NOISE_HEIGHT, true, 0xffffff00 );
					var now:Date = new Date();
					//_noise.noise( int(now.time), 0, 255 );	// plain noise is kinda dull
					_noise.perlinNoise( 4, 4, 3, int(now.time), true, false );
				}
				
				_bands = new Vector.<Bitmap>( Const.FRAMES, true );
				for( i=0; i<Const.FRAMES; i++ ) {
					bData = new BitmapData( 1, 1, true, 0x0 );
					var bmp:Bitmap = new Bitmap( bData, PixelSnapping.ALWAYS, false );
					bmp.x = i * Const.GRAPH_SCALE_X;
					addChild( bmp );
					_bands[i] = bmp;
				}
				
				break;
		}
		
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;	// VOICED or UNVOICED, or maybe PITCH
	private var _id :int;
	private var _rect :Rectangle;
	private var _isEditable :Boolean;
	
	// Voiced paint splotches
	private var _circData :Vector.<BitmapData>;
	private var _circs :Vector.<Bitmap>;
	private var _dotData :BitmapData;
	private var _dots :Vector.<Bitmap>;
	
	// Unvoiced color-cycling noise
	private static var _noise :BitmapData;
	private var _bands :Vector.<Bitmap>;
	
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
		var atX:Number;
		var atY:Number;
		var atHeight :Number;
		var operator:Operator;
		
		switch( _type ) {
			case Const.VOICED:
				operator = fseq.voiced(_id);

				for( f=leftFrame; f<=rightFrame; f++ ) {
					atX = f * Const.GRAPH_SCALE_X;
					atY = yAtFrame(fseq, f);
					_dots[f].y = atY;

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
					
					_circs[f].x = atX - _circs[f].bitmapData.width / 2;
					_circs[f].y = atY - _circs[f].bitmapData.height / 2;
				}
				break;
			
			case Const.UNVOICED:
				operator = fseq.unvoiced(_id);
				
				for( f=leftFrame; f<=rightFrame; f++ ) {
					atX = f * Const.GRAPH_SCALE_X;
					atHeight = Num.interpolate( MIN_NOISE_DISPLAY_HEIGHT, NOISE_HEIGHT, operatorInSequence(fseq).frame(f).amp );
					atY = yAtFrame(fseq, f);	// this is the y center of our bitmap
					
					// For each frame that needs to be redrawn, create a new column by resampling the _noise.
					var bData:BitmapData = new BitmapData( Math.ceil(Const.GRAPH_SCALE_X), atHeight, true, 0x0 );
					var mtx:Matrix = new Matrix();
					mtx.translate( -(atX % NOISE_WIDTH), -((NOISE_HEIGHT - atHeight)/2) );
					bData.draw( _noise, mtx );
					
					// Now set the Bitmap with the new noise sliver graphic
					with( _bands[f] ) {
						bitmapData = bData;
						y = atY - atHeight/2;
					}
				}
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

