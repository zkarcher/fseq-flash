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
import fseq.net.*;
import fseq.net.audiofile.*;
import fseq.view.*;

public class AudioImportView extends Sprite
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function AudioImportView( inParser:BaseParser ) {
		_parser = inParser;
		
		_bg = new Shape();
		with( _bg.graphics ) {
			beginFill( 0xFBB829, 1.0 );
			drawRect( 0, 0, 1000, 1000 );
			endFill();
		}
		addChild( _bg );
		
		_progBar = new Shape();
		with( _progBar.graphics ) {
			beginFill( 0x0066ff, 1.0 );
			drawRect( 0, 0, 1000, 1000 );
			endFill();
		}
		_progBar.blendMode = BlendMode.DIFFERENCE;
		
		addEventListener( Event.ENTER_FRAME, initEnterFrame );
		
		_label = new CustomTextView( " ", {color:0x333333} );
		_label.x = 30;
		_label.y = 20;
		addChild( _label );
		
		// Analyze & display audio 1 frame per step, so Flash doesn't time out :P
		addEventListener( Event.ENTER_FRAME, enterFrame, false, 0, true );
	}
	
	private function initEnterFrame( e:Event ) :void {
		if( !stage ) return;
		removeEventListener( Event.ENTER_FRAME, initEnterFrame );
		
		resize();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _bg :Shape;
	private var _progBar :Shape;
	
	// Steps to import audio:
	private var _label :CustomTextView;
	private var _labelIsDirty :Boolean = true;
	private var _parser :BaseParser;	// contains audio information
	private var _spectrum :SpectralAnalysis;
	private var _spectrumView :SpectralAnalysisView;
	private var _fseq :FormantSequence;
	private var _pitchDetector :PitchDetector;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get fseq() :FormantSequence { return _fseq; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function resize( e:Event=null ) :void {
		if( !stage ) return;
		
		_bg.width = stage.stageWidth;
		_bg.height = stage.stageHeight;
	}
	
	private function enterFrame( e:Event ) :void {
		if( !_spectrum ) {
			if( _labelIsDirty ) {
				_label.text = "Analyzing spectrum...";
				_labelIsDirty = false;
			} else {
				_spectrum = new SpectralAnalysis( _parser );
				_spectrumView = new SpectralAnalysisView( _spectrum, new Rectangle(0,0,Const.FRAMES*Const.GRAPH_SCALE_X,Const.GRAPH_FREQ_HEIGHT) );
				_spectrumView.x = 30;
				_spectrumView.y = 100;
				addChild( _spectrumView );
				_labelIsDirty = true;
			}
			
		} else if( !_fseq ) {
			if( _labelIsDirty ) {
				_label.text = "Analyzing pitch...";
				_labelIsDirty = false;
			} else {
				_fseq = new FormantSequence();
				_pitchDetector = new PitchDetector( _parser, 50.0, 300.0 );

				_progBar.visible = true;
				_progBar.width = 1;
				_progBar.height = _spectrumView.height;
				_progBar.x = _spectrumView.x;
				_progBar.y = _spectrumView.y;
				addChild( _progBar );
			}
			
		} else if( _pitchDetector && !_pitchDetector.isComplete ) {
			// Process as many audio frames as possible within one visual frame in Flash
			var time:Number = 0;
			for( var i:int=0; i<Const.FRAMES; i++ ) {
				time += _pitchDetector.detectNext();
				if( _pitchDetector.isComplete ) {
					for( var f:int=0; f<Const.FRAMES; f++ ) {
						_fseq.pitch().frame(f).freq = _pitchDetector.pitchAt(f);
					}
					break;
				}
				if( time > 1.0/30 ) break;
			}
			
			_progBar.width = (Number(_pitchDetector.index) / Const.FRAMES) * _spectrumView.width;
		}
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

