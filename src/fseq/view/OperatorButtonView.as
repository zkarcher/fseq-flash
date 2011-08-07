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

public class OperatorButtonView extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	public static const ALL_VOICED :String = "ALL_VOICED";
	public static const ALL_UNVOICED :String = "ALL_UNVOICED";
	public static const ALL :String = "ALL";
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function OperatorButtonView( inType:String, inId:int=-1 ) {
		_mc = new OperatorButton_mc();
		_type = inType;
		_id = inId;
		
		switch( _type ) {
			case ALL_VOICED:
			case ALL_UNVOICED:
				_mc.gotoAndStop('wide');
				_mc.tf.text = "<< ALL";
				break;
				
			case ALL:
				_mc.gotoAndStop('plus');
				_mc.tf.text = "+";
				break;
				
			// Regular (small) numbered operator buttons
			default:
				_mc.gotoAndStop('small');
				_mc.tf.text = (_id+1).toString();
				ColorUtil.multiply( _mc, Const.color( _type, _id ) );
				break;
		}
		
		addChild( _mc );
		
		// Add a noisy visual effect to Unvoiced buttons
		if( _type == Const.UNVOICED ) {
			// Brighter button art so the noise doesn't darken it
			var rgb:Object = ColorUtil.rgb(Const.color(_type,_id));
			_mc.transform.colorTransform = new ColorTransform( 
				rgb.r/255*1.3, rgb.g/255*1.3, rgb.b/255*1.3, 1, 
				0,0,0,0
			);
	
			var bData:BitmapData = new BitmapData( _mc.width-16, _mc.height-16, false, 0x0 );
			bData.perlinNoise( 5, 5, 2, inId, false, false, 7, true );
			bData.colorTransform( bData.rect, new ColorTransform(4,4,4,4, 0,0,0,0));	// high contrast
	
			var noise:Bitmap = new Bitmap( bData, PixelSnapping.ALWAYS, false );
			noise.x = noise.y = 8;
			noise.blendMode = BlendMode.MULTIPLY;
			noise.alpha = 1.0;
			addChild( noise );
		}
		
		_mc.tf.mouseEnabled = false;
		
		isOn = true;
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;
	private var _id :int;
	private var _mc :OperatorButton_mc;
	private var _isOn :Boolean = true;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get type() :String { return _type; }
	public function get id() :int { return _id; }
	public function get isNumbered() :Boolean { return _id >= 0; }
	
	public function get isOn() :Boolean { return _isOn; }
	public function set isOn( b:Boolean ) :void {
		_isOn = b;
		var dark:Number = Const.INACTIVE_BRIGHTNESS;
		transform.colorTransform = (b ? new ColorTransform() : new ColorTransform(dark,dark,dark,1, 0,0,0,0) );
	}
	
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

