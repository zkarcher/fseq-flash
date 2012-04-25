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
	
	// Editor tools
	public static const FREEHAND :String = "freehand";
	public static const LINE :String = "line";
	public static const TRANSPOSE :String = "transpose";
	public static const VOWEL_DRAW :String = "vowel_draw";
	public static const FUNC_DRAW :String = "function_draw";
	public static const ALL_TOOLS :Array = [FREEHAND,LINE,TRANSPOSE,VOWEL_DRAW,FUNC_DRAW];
	
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
	private var _isActive :Boolean = false;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get type() :String { return _type; }
	public function get isActive() :Boolean { return _isActive; }
	
	public function set hilite( b:Boolean ) :void {
		_isActive = b;
		if( _isActive ) {
			transform.colorTransform = new ColorTransform();
		} else {
			transform.colorTransform = new ColorTransform( 0.4, 0.4, 0.4, 1, 0,0,0,0 );	// darker grey
		}
	}
	
	// Edit types: FREEHAND tool type -> EDIT_FREEHAND_DRAW, etc.
	public function get editType() :String { return EditType.typeForTool(_type); }
	
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

