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
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function OperatorView( type:String, id:int, rect:Rectangle ) {
		_type = type;
		_id = id;
		_rect = rect;
		
		var i:int;
		
		switch( _type ) {
			case Const.VOICED:
			case Const.UNVOICED:	// <-- TODO: this is temporary
				_bData = new BitmapData( 2, 2, false, Const.color(_type,_id) );
				_dots = new Vector.<Bitmap>();
				for( i=0; i<Const.FRAMES; i++ ) {
					var dot:Bitmap = new Bitmap( _bData, PixelSnapping.NEVER, true );
					dot.x = (i*Const.GRAPH_SCALE_X)-1;
					dot.y = -100;	// start off-screen
					addChild( dot );
					_dots.push( dot );
				}
				break;
				/*
			case Const.UNVOICED:
				_bData = new BitmapData( 1, 1, false, Const.color(_type,_id) );
				break;
				*/
		}
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _type :String;	// VOICED or UNVOICED, or maybe PITCH
	private var _id :int;
	private var _rect :Rectangle;
	
	private var _bData :BitmapData;
	private var _dots :Vector.<Bitmap>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function redraw( fseq:FormantSequence ) :void {
		var operator:Operator;
		switch( _type ) {
			case Const.VOICED:		operator = fseq.voiced(_id); break;
			case Const.UNVOICED:	operator = fseq.unvoiced(_id); break;
		}
		
		for( var f:int=0; f<Const.FRAMES; f++ ) {
			_dots[f].y = _rect.height * (1 - operator.frame(f).freq * (1/7000.0));
			_dots[f].alpha = 0.15 + 0.85*operator.frame(f).amp;
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

