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
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function OperatorButtonView( inType:String, inId:int ) {
		_type = inType;
		_id = inId;
		
		_mc = new OperatorButton_mc();
		_mc.tf.text = (_id+1).toString();
		ColorUtil.multiply( _mc, Const.color( _type, _id ) );
		addChild( _mc );
		
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

