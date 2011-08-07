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
import fl.controls.*;
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
		
		_skip = new BasicButton("Skip");
		_skip.addEventListener( MouseEvent.CLICK, skipClick, false, 0, true );
		_skip.x = 400;
		_skip.y = 18;

		_ok = new BasicButton("OK!");
		_ok.addEventListener( MouseEvent.CLICK, okClick, false, 0, true );
		_cancel = new BasicButton("Cancel");
		_cancel.addEventListener( MouseEvent.CLICK, cancelClick, false, 0, true );
		_cancel.x = 180;
		_ok.x = 30;
		_ok.y = _cancel.y = 650;
		addChild( _cancel );
		
		_formantComboBox = new ComboBox();
		var index:int = 0;
		for each( var type:String in DetectionType.ALL_FORMANT_DETECTORS ) {
			_formantComboBox.addItem( {label:type, data:type} );
			if( type == _formantType ) _formantComboBox.selectedIndex = index;
			index++;
		}
		_formantComboBox.width += 100;
		_formantComboBox.addEventListener( Event.CHANGE, formantComboBoxChangeHandler, false, 0, true );
		_formantComboBox.x = 800;
		_formantComboBox.y = 60;
		addChild( _formantComboBox );
		
		var label:CustomTextView = new CustomTextView( "formant algorithm:", {color:0x0, size:12} );
		label.x = _formantComboBox.x - label.textWidth - 18;
		label.y = _formantComboBox.y + 6;
		addChild( label );
		
		// Analyze & display audio 1 frame per step, so Flash doesn't time out :P
		addEventListener( Event.ENTER_FRAME, enterFrame, false, 0, true );
	}
	
	private function initEnterFrame( e:Event ) :void {
		if( !stage ) return;
		removeEventListener( Event.ENTER_FRAME, initEnterFrame );
		
		resize();
	}
	
	public function destroy() :void {
		if( parent ) parent.removeChild( this );
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _bg :Shape;
	private var _progBar :Shape;
	private var _scan :Bitmap;	// vertical bar sweeps during playback
	
	// Steps to import audio:
	private var _wasReadyLastFrame :Boolean = false;
	private var _label :CustomTextView;
	private var _isLabelDirty :Boolean = true;
	private var _parser :BaseParser;	// contains audio information
	private var _spectrum :SpectralAnalysis;
	private var _spectrumView :SpectralAnalysisView;
	private var _fseq :FormantSequence;
	private var _pitchDetector :PitchDetector;
	private var _isPitchSet :Boolean = false;
	private var _formantDetector :FormantDetector;
	private var _opViews :Vector.<OperatorView>;
	
	// Settings
	private static var _formantType :String = DetectionType.FORMANTS_LIGHT;
	private var _formantComboBox :ComboBox;
	
	// Buttons
	private var _skip :BasicButton;
	private var _ok :BasicButton;
	private var _cancel :BasicButton;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get fseq() :FormantSequence { return _fseq; }
	public function get fseqIsReady() :Boolean {
		return _parser && _spectrum && _fseq && _pitchDetector && _pitchDetector.isComplete && _formantDetector && _formantDetector.isComplete;
	}
		
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function scanGlow( f:int ) :void {
		if( !_scan && _spectrumView ) {
			_scan = new Bitmap( new BitmapData( Math.ceil(Const.GRAPH_SCALE_X), _spectrumView.height, false, 0xffff00 ));
			_scan.y = _spectrumView.y;
			_scan.alpha = 0.5;
		}
		if( _scan ) {
			addChild( _scan );	// always display on top
			_scan.x = f * Const.GRAPH_SCALE_X;
		}
	}
	
	public function teardown() :void {
		mouseEnabled = mouseChildren = false;
		removeEventListener( Event.ENTER_FRAME, enterFrame );
		Tweener.addTween( this, {y:-height, transition:"easeInSine", time:0.4, onComplete:destroy});
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function resize( e:Event=null ) :void {
		if( !stage ) return;
		
		_bg.width = stage.stageWidth;
		_bg.height = stage.stageHeight;
	}
	
	private function enterFrame( e:Event ) :void {
		var f:int, i:int;
		var time:Number;
		
		if( !_spectrum ) {
			//
			// SPECTRAL ANALYSIS
			//
			if( _isLabelDirty ) {
				_label.text = "Analyzing spectrum...";
				_isLabelDirty = false;
			} else {
				_spectrum = new SpectralAnalysis( _parser );
				_spectrumView = new SpectralAnalysisView( _spectrum, new Rectangle(0,0,Const.FRAMES*Const.GRAPH_SCALE_X,Const.GRAPH_FREQ_HEIGHT) );
				_spectrumView.x = 30;
				_spectrumView.y = 100;
				addChild( _spectrumView );
				_isLabelDirty = true;
			}
			
		} else if( !_fseq ) {
			//
			// PITCH DETECTION
			//
			if( _isLabelDirty ) {
				_label.text = "Detecting pitch...";
				_isLabelDirty = false;
			} else {
				_fseq = new FormantSequence();
				_pitchDetector = new PitchDetector( _parser, 55.0, 880.0 );
				showProgBar();
				if( _skip && !_skip.parent ) addChild( _skip );
			}
			
		} else if( _pitchDetector && !_pitchDetector.isComplete ) {
			hideFseqView();
			
			// Process as many audio frames as possible within one visual frame in Flash
			time = 0;
			for( i=0; i<Const.FRAMES; i++ ) {
				time += _pitchDetector.detectNext();
				if( _pitchDetector.isComplete ) {
					// Pitch detection is complete!
					if( _skip && _skip.parent ) _skip.parent.removeChild( _skip );
					break;
				}
				
				// Have we processed more than one visual frame's worth of data?
				if( time > 1.0/30 ) break;
			}
			
			_progBar.width = (Number(_pitchDetector.index) / Const.FRAMES) * _spectrumView.width;
			_isLabelDirty = true;
			
		} else if( !_isPitchSet ) {
			for( f=0; f<Const.FRAMES; f++ ) {
				_fseq.pitch().frame(f).freq = _pitchDetector.pitchAt(f);
			}
			_isPitchSet = true;
			
		} else if( !_formantDetector ) {
			if( _skip && _skip.parent ) _skip.parent.removeChild( _skip );
			hideFseqView();
			
			//
			// FORMANT DETECTION
			//
			if( _isLabelDirty ) {
				_label.text = "Detecting formants...";
				_isLabelDirty = false;
			} else {
				switch( _formantType ) {
					case DetectionType.VOCODER:
						break;
					
					default:
						_formantDetector = new FormantDetector( _spectrum, _fseq.pitch(), DetectionType.smoothness(_formantType) );
						break;
				}
				showProgBar();
			}

		} else if( _formantDetector && !_formantDetector.isComplete ) {
			time = 0;
			for( i=0; i<Const.FRAMES; i++ ) {
				time += _formantDetector.detectNext();
				if( _formantDetector.isComplete ) {
					// Finished, so copy the formant data into the fseq.
					for( f=0; f<Const.FRAMES; f++ ) {
						for( var op:int=0; op<Const.VOICED_OPS; op++ ) {
							// Copy all the formant sequence data
							_fseq.voiced(op).frame(f).amp = _formantDetector.voicedFrame( f, op ).amp;
							_fseq.voiced(op).frame(f).freq = _formantDetector.voicedFrame( f, op ).freq;
							_fseq.unvoiced(op).frame(f).amp = _formantDetector.unvoicedFrame( f, op ).amp;
							_fseq.unvoiced(op).frame(f).freq = _formantDetector.unvoicedFrame( f, op ).freq;
						}
					}
					_fseq.normalize();
					break;
				}
				
				// Have we processed more than one visual frame's worth of data?
				if( time > 1.0/30 ) break;
			}
			
			_progBar.width = (Number(_formantDetector.index) / Const.FRAMES) * _spectrumView.width;
			_isLabelDirty = true;
			
		} else {
			hideProgBar();
		}
		
		// FSEQ is ready?
	 	if( !_wasReadyLastFrame && fseqIsReady ) {
			_label.visible = false;
			showFseqView();
			addChild( _ok );
		} else if( _wasReadyLastFrame && !fseqIsReady ) {
			_label.visible = true;
			hideFseqView();
			_ok.parent.removeChild( _ok );
		}
		
		_wasReadyLastFrame = fseqIsReady;
	}
	
	//
	// DETECTION TYPE CHANGES
	//
	private function formantComboBoxChangeHandler( e:Event ) :void {
		// Don't let the dropdown keep the focus
		if( stage ) stage.focus = null;

		_formantType = _formantComboBox.value;	// store this for later
		_formantDetector = null;	// on next enterFrame, this will be recreated
	}
	
	//
	// BUTTONS
	//
	private function skipClick( e:MouseEvent ) :void {
		if( _pitchDetector ) {
			_pitchDetector.skipRemaining();
		}
	}
	
	private function okClick( e:MouseEvent ) :void {
		dispatchEvent( new CustomEvent( CustomEvent.FSEQ_COMPLETE ));
	}

	private function cancelClick( e:MouseEvent ) :void {
		dispatchEvent( new CustomEvent( CustomEvent.CANCEL ));
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	private function showProgBar() :void {
		_progBar.visible = true;
		_progBar.width = 1;
		_progBar.height = _spectrumView.height;
		_progBar.x = _spectrumView.x;
		_progBar.y = _spectrumView.y;
		addChild( _progBar );
	}
	
	private function hideProgBar() :void {
		if( _progBar && _progBar.parent ) _progBar.parent.removeChild( _progBar );
	}
	
	private function showFseqView() :void {
		var rect:Rectangle = new Rectangle( 0, 0, _spectrumView.width, _spectrumView.height );
		_opViews = new Vector.<OperatorView>();
		var i:int;
		for( i=0; i<Const.VOICED_OPS; i++ ) {
			_opViews.push( new OperatorView( Const.VOICED, i, rect ));
		}
		for( i=0; i<Const.UNVOICED_OPS; i++ ) {
			_opViews.unshift( new OperatorView( Const.UNVOICED, i, rect ));	// draw noise ops under the pitched ops
		}
		_opViews.push( new OperatorView( Const.PITCH, 0, rect ));
		
		// Add all the opViews to the canvas
		for each( var opView:OperatorView in _opViews ) {
			opView.scrollRect = rect;
			opView.redraw( _fseq, 0, Const.FRAMES-1 );
			opView.x = _spectrumView.x;
			opView.y = _spectrumView.y;
			opView.alpha = 0.7;
			addChild( opView );
		}
	}
	
	private function hideFseqView() :void {
		if( _opViews ) {
			for each( var opView:OperatorView in _opViews ) {
				opView.destroy();
			}
		}
		_opViews = null;
	}
}

}

