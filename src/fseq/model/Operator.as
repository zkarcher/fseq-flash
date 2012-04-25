package fseq.model {

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
import fseq.model.*;

public class Operator extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function Operator( inType:String, inIndex:int=-1, inFrames:Vector.<OperatorFrame>=null ) {
		super();
		
		_type = inType;
		_index = inIndex;
		
		if( inFrames ) {
			_frames = inFrames;
		} else {
			// Start with empty frames
			_frames = new Vector.<OperatorFrame>;
			for( var i:int=0; i<Const.FRAMES; i++ ) {
				_frames.push( new OperatorFrame(0,0) );
			}
		}
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;
	
	// Voiced & unvoiced indexes count from _0_, so indexes 0..7 appear in the app as 1..8 .
	// Pitch Operator can have any index, we don't care!
	private var _index :int = -1;
	
	private var _frames :Vector.<OperatorFrame>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get isVoiced() :Boolean { return _type == Const.VOICED; }
	public function get isUnvoiced():Boolean { return _type == Const.UNVOICED; }
	public function get isPitch() :Boolean { return _type == Const.PITCH; }
	public function get index() :int { return _index; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function frame( id:int ) :OperatorFrame {
		return _frames[ id ];
	}
	
	public function clone() :Operator {
		var useFrames:Vector.<OperatorFrame> = new Vector.<OperatorFrame>();
		for( var i:int=0; i<Const.FRAMES; i++ ) {
			useFrames.push( _frames[i].clone() );
		}
		return new Operator( _type, _index, useFrames );
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

