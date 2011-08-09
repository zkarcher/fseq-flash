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
import flash.filters.*;
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
	private static const NOISE_VARIATIONS :int = 10;
	
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
					_circSizes++;
				}
				
				// Now that our bitmap data(s) are ready, create all the Bitmaps for the operator
				_circs = new Vector.<Bitmap>( Const.FRAMES, true );
				for( i=0; i<Const.FRAMES; i++ ) {
					_circs[i] = new Bitmap( _circData[0], PixelSnapping.ALWAYS, false );
					_circs[i].x = i*Const.GRAPH_SCALE_X - (MAX_CIRC_RADIUS-1);
					addChild( _circs[i] );
				}
				
				_dotData = new BitmapData( 1, 1, false, Const.color( Const.VOICED_DOT ) );
				_dots = new Vector.<Bitmap>( Const.FRAMES, true );
				for( i=0; i<Const.FRAMES; i++ ) {
					_dots[i] = new Bitmap( _dotData, PixelSnapping.ALWAYS, false );
					_dots[i].x = i*Const.GRAPH_SCALE_X;
					addChild( _dots[i] );
				}		
				
				// The circles will overlap, so render as a single layer (looks better when dimmed)
				blendMode = BlendMode.LAYER;
				
				break;

			case Const.UNVOICED:
				_circData = new Vector.<BitmapData>();
				for( i=0; i<MAX_CIRC_RADIUS-2; i++ ) {
					var basicCircle:BitmapData = new BitmapData( i*2+3, i*2+3, true, 0x0 );
					shp = new Shape();
					with( shp.graphics ) {
						beginFill( color, 1.0 );
						drawCircle( basicCircle.width/2, basicCircle.height/2, i+1.5 );
						endFill();
					}
					basicCircle.draw( shp );
					
					// Don't tint everything 100%, let some of the noise leak through
					var rgb:Object = ColorUtil.rgb( color );
					var xform:ColorTransform = new ColorTransform( rgb.r/255,rgb.g/255,rgb.b/255,1, 0,0,0,0 );
					
					for( var v:int=0; v<NOISE_VARIATIONS; v++ ) {
						bData = new BitmapData( basicCircle.width, basicCircle.height, true, 0xff000000 );
						bData.noise( Rand.int(int.MAX_VALUE), 0, 255, 15, true );
						bData.colorTransform( bData.rect, xform );
						// circular cutout:
						//bData.copyChannel( basicCircle, bData.rect, new Point(0,0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA );
						_circData.push( bData );
					}
					
					_circSizes++;
				}

				// Now that our bitmap data(s) are ready, create all the Bitmaps for the operator
				_circs = new Vector.<Bitmap>( Const.FRAMES, true );
				for( i=0; i<Const.FRAMES; i++ ) {
					_circs[i] = new Bitmap( _circData[0], PixelSnapping.ALWAYS, false );
					_circs[i].x = i*Const.GRAPH_SCALE_X - (MAX_CIRC_RADIUS-1);
					addChild( _circs[i] );
				}
				
				// The circles will overlap, so render as a single layer (looks better when dimmed)
				blendMode = BlendMode.LAYER;
				
				break;
		}
	}
	
	public function destroy() :void {
		if( parent ) parent.removeChild( this );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;	// VOICED or UNVOICED, or maybe PITCH
	private var _id :int;
	private var _rect :Rectangle;
	private var _isEditable :Boolean;
	
	// Pitch line
	private var _line :Shape;
	
	// Voiced & unvoiced paint splotches
	private var _circSizes :int = 0;
	private var _circData :Vector.<BitmapData>;
	private var _circs :Vector.<Bitmap>;
	private var _dotData :BitmapData;
	private var _dots :Vector.<Bitmap>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get type() :String { return _type; }
	public function get id() :int { return _id; }
	
	public function get isEditable() :Boolean { return _isEditable; }
	public function set isEditable( b:Boolean ) :void {
		_isEditable = b;
		alpha = b ? 1.0 : Const.INACTIVE_BRIGHTNESS;
	}
	
	// Hilite when the mouse hovers near this OperatorView, for example
	public function set hilite( b:Boolean ) :void {
		if( b ) {
			var dark:Number = Const.INACTIVE_BRIGHTNESS;
			if( type == Const.PITCH ) {
				this.transform.colorTransform = new ColorTransform( dark,dark,dark,1, 0x7f,0x7f,0x3f,0 );	// yellow tint
			} else {
				this.transform.colorTransform = new ColorTransform( dark,dark,dark,1, 0x7f,0x7f,0x7f,0 );
			}
		} else {
			this.transform.colorTransform = new ColorTransform();
		}
	}
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function operatorInSequence( fseq:FormantSequence ) :Operator {
		if( !fseq ) return null;
		
		switch( _type ) {
			case Const.PITCH:	return fseq.pitch();
			case Const.VOICED:	return fseq.voiced(_id);
			case Const.UNVOICED: return fseq.unvoiced(_id);
		}
		return null;
	}
	
	public function yAtFrame( fseq:FormantSequence, f:int ) :Number {
		if( !fseq ) return -1;
		
		var operator:Operator = operatorInSequence( fseq );
		return GraphView.freqToY( _rect.height, operator.frame(f).freq );
	}
		
	public function redraw( fseq:FormantSequence, leftFrame:int, rightFrame:int ) :void {
		if( !fseq ) return;
		
		var f:int;
		var atX:Number;
		var atY:Number;
		var atHeight :Number;
		var operator:Operator;
		
		switch( _type ) {
			case Const.PITCH:
				var color:uint = Const.color( _type );
				if( _line && _line.parent ) _line.parent.removeChild( _line );
				
				_line = new Shape();
				_line.graphics.lineStyle( 1.5, color, 1.0 );
				_line.graphics.moveTo( 0, yAtFrame(fseq,0) );
				for( f=1; f<Const.FRAMES; f++ ) {
					_line.graphics.lineTo( f * Const.GRAPH_SCALE_X, yAtFrame(fseq,f) );
				}
				addChild( _line );
				break;
			
			case Const.VOICED:
			case Const.UNVOICED:
				operator = (_type==Const.VOICED) ? fseq.voiced(_id) : fseq.unvoiced(_id);

				for( f=leftFrame; f<=rightFrame; f++ ) {
					atX = f * Const.GRAPH_SCALE_X;
					atY = yAtFrame(fseq, f);
					if( _type == Const.VOICED ) {
						_dots[f].y = atY;
					}
					
					// Change the circle size, if necessary.
					// Louder frames have larger circles.
					var amp:Number = operator.frame(f).amp;
					var ampCompare :Number = 0.5;
					var circId:int = _circSizes-1;
					while( circId > 0 && amp < ampCompare ) {
						ampCompare *= 0.5;
						circId--;
					}
					
					// Unvoiced has many noise variations to choose from
					if( _type == Const.UNVOICED ) {
						circId *= NOISE_VARIATIONS;
						circId += Rand.int( NOISE_VARIATIONS );
					}
					
					_circs[f].bitmapData = _circData[circId];
					
					_circs[f].x = atX - _circs[f].bitmapData.width / 2;
					_circs[f].y = atY - _circs[f].bitmapData.height / 2;
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

