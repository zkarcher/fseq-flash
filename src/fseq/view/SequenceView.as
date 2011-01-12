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

public class SequenceView extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function SequenceView( mode:String, seq:FormantSequence ) {
		_bg = new Shape();
		with( _bg.graphics ) {
			beginFill( 0x0, 1.0 );
			drawRect( 0, 0, 512, 512 );
			endFill();
		}
		addChild( _bg );
		
		var lines:Sprite = new Sprite();
		addChild( lines );
		
		var op:int, f:int, color:uint;
		
		// VOICED
		for( op=0; op<8; op++ ) {
			color = Const.color( Const.VOICED, op );
			//lines.graphics.lineStyle( 1, color, 1.0 );
			//lines.graphics.moveTo( 0,0 );
			
			for( f=0; f<512; f++ ) {
				if( mode == Const.FREQ ) {
					//lines.graphics.lineTo( f, 512 - seq.voiced(op).frame(f).freq * (512.0/0x3fff) );
					with( lines.graphics ) {
						beginFill( color, 1.0 );
						drawRect( f, 512 - seq.unvoiced(op).frame(f).freq * (512.0/0x3fff), 1, 1 );	// one dot
						//drawRect( 0, 512 - seq.unvoiced(op).frame(f).freq * (512.0/0x3fff), 512, 1 );	// horiz line
						endFill();
					}
					
				} else if( mode == Const.AMP ) {
					trace("TODO");
					
				}
			}
		}
		
		// UNVOICED
		for( op=0; op<8; op++ ) {
			color = Const.color( Const.UNVOICED, op );
			//lines.graphics.lineStyle( 1, color, 1.0 );
			//lines.graphics.moveTo( 0,0 );
			
			for( f=0; f<512; f++ ) {
				if( mode == Const.FREQ ) {
					with( lines.graphics ) {
						beginFill( color, 1.0 );
						drawRect( f, 512 - seq.unvoiced(op).frame(f).freq * (512.0/0x3fff), 1, 1 );	// one dot
						//drawRect( 0, 512 - seq.unvoiced(op).frame(f).freq * (512.0/0x3fff), 512, 1 );	// horiz line
						endFill();
					}
					//lines.graphics.lineTo( f, 512 - seq.unvoiced(op).frame(f).freq * (512.0/0x3fff) );
					
				} else if( mode == Const.AMP ) {
					trace("TODO");
					
				}
			}
		}
		
		// PITCH
		if( mode == Const.FREQ ) {
			color = Const.color( Const.PITCH );
			lines.graphics.lineStyle( 1, color, 1.0 );
			lines.graphics.moveTo( 0,0 );
			for( f=0; f<512; f++ ) {
				lines.graphics.lineTo( f, 512 - seq.pitch().frame(f).freq * (512.0/0x3fff));
			}
		}
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _bg :Shape;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
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

