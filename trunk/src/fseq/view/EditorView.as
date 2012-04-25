package fseq.view {

/**
 *	Manages the following:
 *    -- 1 GraphView, displaying the Operator frequencies over time.
 *    -- (Eventually there will be a second, smaller GraphView for the amplitudes.)
 *    -- Buttons for Operators & Tools.
 *    -- EditorHistory object, which makes undo/redo operations possible.
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
		
		button = new OperatorButtonView( Const.PITCH );
		button.x = 5;
		button.y = _freqView.y + Const.GRAPH_FREQ_HEIGHT + 62;
		_opButtons.push( button );
		
		for( i=0; i<Const.VOICED_OPS; i++ ) {
			button = new OperatorButtonView( Const.VOICED, i );
			button.x = i * 70 + 100;
			button.y = _freqView.y + Const.GRAPH_FREQ_HEIGHT + 20;
			_opButtons.push( button );
		}
		for( i=0; i<Const.UNVOICED_OPS; i++ ) {
			button = new OperatorButtonView( Const.UNVOICED, i );
			button.x = i * 70 + 100;
			button.y = _freqView.y + Const.GRAPH_FREQ_HEIGHT + 80;
			_opButtons.push( button );
		}
		
		// Special buttons: << ALL VOICED, etc
		for each( var type:String in [OperatorButtonView.ALL_VOICED, OperatorButtonView.ALL_UNVOICED] ) {
			button = new OperatorButtonView( type );
			button.x = Const.VOICED_OPS * 70 + 112;
			button.y = _freqView.y + Const.GRAPH_FREQ_HEIGHT + ((type==OperatorButtonView.ALL_UNVOICED) ? 92 : 28);
			_opButtons.push( button );
		}
		
		// ALL "+" button
		button = new OperatorButtonView( OperatorButtonView.ALL );
		button.x = Const.VOICED_OPS * 70 + 140;
		button.y = _freqView.y + Const.GRAPH_FREQ_HEIGHT + 62;
		_opButtons.push( button );
		
		// Add the listeners & add to stage
		for each( button in _opButtons ) {
			button.addEventListener( MouseEvent.CLICK, opButtonClick, false, 0, true );
			addChild( button );
		}
		
		// All ops, including Pitch, are editable when the app launches
		var t:Boolean = true;
		setEditableOps( t, [t,t,t,t, t,t,t,t], [t,t,t,t, t,t,t,t] );
		
		_toolButtons = new Vector.<ToolButtonView>();
		var atX:Number = 10;
		for each( var str:String in ToolButtonView.ALL_TOOLS ) {
			var toolButton:ToolButtonView = new ToolButtonView( str );
			toolButton.addEventListener( MouseEvent.CLICK, toolClick, false, 0, true );
			toolButton.x = atX;
			toolButton.y = -30;
			atX += toolButton.width + 10;
			addChild( toolButton );
			_toolButtons.push( toolButton );
		}
		hiliteToolButton( _toolButtons[0] );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _history :EditorHistory;

	private var _freqView :GraphView;
	//private var _ampView :GraphView;
	
	private var _opButtons :Vector.<OperatorButtonView>;
	private var _toolButtons :Vector.<ToolButtonView>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get activeSequence() :FormantSequence {
		return _history.activeSequence;
	}
	
	public function get activeTool() :ToolButtonView { 
		for each( var tb:ToolButtonView in _toolButtons ) {
			if( tb.isActive ) return tb;
		}
		trace("** EditorView.activeTool: No active tool!");
		return tb;
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
	
	public function undo() :void {
		_history.undo();
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
		var clickedBtn:OperatorButtonView = OperatorButtonView( e.currentTarget );
		var btn:OperatorButtonView;	// temporary variable
		
		if( clickedBtn.isNumbered || clickedBtn.type==Const.PITCH ) {
			// If the shift key is pressed, don't cancel any other buttons
			if( e.shiftKey ) {
				clickedBtn.isOn = !clickedBtn.isOn;
			} else {
				for each( btn in _opButtons ) {
					// Enable only the button that was clicked
					if( btn.isNumbered || btn.type==Const.PITCH ) btn.isOn = (btn == clickedBtn);
				}
			}
			
		// Special buttons
		} else {
			// When the user shift-clicks special buttons, if the target buttons are all ON, then turn them OFF.
			// Keep track of the target buttons that were ON.
			var targetsWereOn:Array = [];
			
			for each( btn in _opButtons ) {
				if( !btn.isNumbered && (btn.type != Const.PITCH) ) continue;	// ignore special buttons, only affect numbered buttons
				
				// If this btn type matches the special button we clcked, then set isOn to true
				var isTargetType:Boolean = (clickedBtn.type == OperatorButtonView.ALL)
							|| (clickedBtn.type == OperatorButtonView.ALL_UNVOICED && btn.type == Const.UNVOICED )
							|| (clickedBtn.type == OperatorButtonView.ALL_VOICED && btn.type == Const.VOICED );
							
				// "+" includes the PITCH button
				if( clickedBtn.type == OperatorButtonView.ALL && btn.type == Const.PITCH ) isTargetType = true;
							
				// Shift key: Leave other buttons on
				if( e.shiftKey ) {
					if( isTargetType && btn.isOn ) targetsWereOn.push( btn );
					btn.isOn = (btn.isOn || isTargetType);
				} else {
					btn.isOn = isTargetType;
				}
			}
			
			// Check to see if the user actually wanted to switch all the targets OFF. (shift key)
			if( e.shiftKey ) {
				switch( clickedBtn.type ) {
					case OperatorButtonView.ALL_UNVOICED:
					case OperatorButtonView.ALL_VOICED:
						if( targetsWereOn.length == 8 ) {
							for each( btn in targetsWereOn ) {
								btn.isOn = false;
							}
						}
						break;
						
					case OperatorButtonView.ALL:
						if( targetsWereOn.length == 17 ) {	// 8 voiced, 8 unvoiced, and the PITCH button
							for each( btn in targetsWereOn ) {
								btn.isOn = false;
							}
						}
						break;
				}
			}
		}
		
		// Update the state of each OperatorView (whether it's drawable, etc)
		var voiced:Array = [];
		var unvoiced:Array = [];
		var isPitchOn:Boolean;
		for each( btn in _opButtons ) {
			switch( btn.type ) {
				case Const.VOICED:		voiced.push( btn.isOn ); break;
				case Const.UNVOICED:	unvoiced.push( btn.isOn ); break;
				case Const.PITCH:		isPitchOn = btn.isOn; break;
			}
		}
		
		setEditableOps( isPitchOn, voiced, unvoiced );
	}
		
	private function activeFseqChangedHandler( e:CustomEvent ) :void {
		if( e.data['redraw'] == true ) {
			_freqView.fseq = _history.activeSequence;
			redrawAllGraphs();
		}
	}
	
	private function toolClick( e:MouseEvent ) :void {
		hiliteToolButton( ToolButtonView(e.currentTarget) );
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
	
	private function hiliteToolButton( tb:ToolButtonView ) :void {
		for each( var oneTB:ToolButtonView in _toolButtons ) {
			oneTB.hilite = (oneTB == tb);
		}
	}
}

}

