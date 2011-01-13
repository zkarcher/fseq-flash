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
		_history = new EditorHistory();
		
		_ampView = new GraphView( Const.AMP );
		addChild( _ampView );
		
		_freqView = new GraphView( Const.FREQ );
		_freqView.y = Const.GRAPH_AMP_HEIGHT + 20;
		addChild( _freqView );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _history :EditorHistory;

	private var _ampView :GraphView;
	private var _freqView :GraphView;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get activeSequence() :FormantSequence {
		return _history.activeSequence;
	}
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function pushSequence( fseq:FormantSequence ) :void {
		_history.pushSequence( fseq );
		redrawGraphs();
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	private function redrawGraphs() :void {
		_ampView.redraw( activeSequence );
		_freqView.redraw( activeSequence );
	}
}

}

