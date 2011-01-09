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
	public function Operator( inFrames:Vector.<OperatorFrame>=null ) {
		super();
		
		if( inFrames ) {
			_frames = inFrames;
		} else {
			// Start with empty frames
			_frames = new Vector.<OperatorFrame>;
			for( var i:int=0; i<FormantSequence.FRAMES; i++ ) {
				_frames.push( new OperatorFrame(0,0) );
			}
		}
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _frames :Vector.<OperatorFrame>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function frame( id:int ) :OperatorFrame {
		return _frames[ id ];
	}
	
	public function clone() :Operator {
		var useFrames:Vector.<OperatorFrame> = new Vector.<OperatorFrame>();
		for( var i:int=0; i<FormantSequence.FRAMES; i++ ) {
			useFrames.push( _frames[i].clone() );
		}
		return new Operator( useFrames );
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

