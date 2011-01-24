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

public class EditorView extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function EditorView() {
		var i:int;
		
		_history = new EditorHistory();
		_history.addEventListener( CustomEvent.ACTIVE_FSEQ_CHANGED, activeFseqChangedHandler );
		
		/*
		_ampView = new GraphView( Const.AMP );
		addChild( _ampView );
		*/
		
		_freqView = new GraphView( Const.FREQ );
		_freqView.y = 40;	//Const.GRAPH_AMP_HEIGHT + 20;
		addChild( _freqView );
		
		with( _freqView ) {
			addEventListener( CustomEvent.EDIT_START, editStart );
			addEventListener( CustomEvent.EDIT_STOP, editStop );
		}
		
		// Operator buttons
		_opButtons = new Vector.<OperatorButtonView>();
		var button:OperatorButtonView;
		for( i=0; i<Const.VOICED_OPS; i++ ) {
			button = new OperatorButtonView( Const.VOICED, i );
			button.x = i * 70;
			button.y = _freqView.y + Const.GRAPH_FREQ_HEIGHT + 20;
			_opButtons.push( button );
		}
		for( i=0; i<Const.UNVOICED_OPS; i++ ) {
			button = new OperatorButtonView( Const.UNVOICED, i );
			button.x = i * 70;
			button.y = _freqView.y + Const.GRAPH_FREQ_HEIGHT + 80;
			_opButtons.push( button );
		}
		for each( button in _opButtons ) {
			button.addEventListener( MouseEvent.CLICK, opButtonClick, false, 0, true );
			addChild( button );
		}
		
		var t:Boolean = true;
		var f:Boolean = false;
		setEditableOps( f, [t,t,t,t, t,t,t,t], [t,t,t,t, t,t,t,t] );
		
		_undo = new BasicButton("undo");
		_undo.addEventListener( MouseEvent.CLICK, undoClick );
		addChild( _undo );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _history :EditorHistory;

	//private var _ampView :GraphView;
	private var _freqView :GraphView;
	
	private var _undo :BasicButton;
	private var _opButtons :Vector.<OperatorButtonView>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get activeSequence() :FormantSequence {
		return _history.activeSequence;
	}
	
	public function get history() :EditorHistory { return _history; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function pushSequence( fseq:FormantSequence ) :void {
		_history.pushSequence( fseq );
		_freqView.fseq = activeSequence;
		redrawAllGraphs();
	}
	
	public function scanGlow( col:int ) :void {
		_freqView.scanGlow( col );
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function editStart( e:CustomEvent ) :void {
		_history.editStart();
		_freqView.fseq = activeSequence;	// any changes will apply to this new FormantSequence
	}
	
	private function editStop( e:CustomEvent ) :void {
		_history.editStop();
	}
	
	private function opButtonClick( e:MouseEvent ) :void {
		var button:OperatorButtonView = OperatorButtonView( e.currentTarget );

		if( e.shiftKey ) {
			button.isOn = !button.isOn;
		} else {
			for each( var btn:OperatorButtonView in _opButtons ) {
				btn.isOn = (btn == button);
			}
		}
		
		var voiced:Array = [];
		var unvoiced:Array = [];
		for each( button in _opButtons ) {
			switch( button.type ) {
				case Const.VOICED:		voiced.push( button.isOn ); break;
				case Const.UNVOICED:	unvoiced.push( button.isOn ); break;
			}
		}
		
		setEditableOps( false, voiced, unvoiced );
	}
	
	private function undoClick( e:MouseEvent ) :void {
		_history.undo();
	}
	
	private function activeFseqChangedHandler( e:CustomEvent ) :void {
		if( e.data['redraw'] == true ) {
			_freqView.fseq = _history.activeSequence;
			redrawAllGraphs();
		}
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	// Set with arrays of Booleans
	private function setEditableOps( pitch:Boolean, voiced:Array, unvoiced:Array ) :void {
		_freqView.setEditableOps( pitch, voiced, unvoiced );
	}
	
	private function redrawAllGraphs() :void {
		//_ampView.redraw( activeSequence );
		_freqView.redrawAll();
	}
}

}

