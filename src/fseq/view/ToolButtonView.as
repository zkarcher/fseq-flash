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

public class ToolButtonView extends ToolButton_mc
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function ToolButtonView( inType:String ) {
		_type = inType;
		gotoAndStop( _type );
		useHandCursor = buttonMode = true;
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get type() :String { return _type; }
	
	public function set hilite( b:Boolean ) :void {
		if( b ) {
			transform.colorTransform = new ColorTransform();
		} else {
			transform.colorTransform = new ColorTransform( 0.4, 0.4, 0.4, 1, 0,0,0,0 );
		}
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

