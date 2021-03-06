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
import flash.text.*;
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.view.*;

public class CustomTextView extends CustomText_mc
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function CustomTextView( str:String, inParams:Object ) {
		_params = inParams || {};
		if( _params.hasOwnProperty('color') ) {
			ColorUtil.tint( tf, _params['color'] );
		}
		
		mouseEnabled = mouseChildren = false;
		text = str;

		if( _params.hasOwnProperty('size') ) {
			var format:TextFormat = new TextFormat();
			format.size = Number( _params['size'] );
			tf.setTextFormat( format );
		}
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _params :Object;
	
	public function get textWidth() :Number { return tf.textWidth; }
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function set text( str:String ) :void {
		tf.text = str;
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

