package fseq.audio {

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
import flash.media.*;
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.audio.*;
import fseq.model.*;

public class AudioPlayer extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	public static const SAMPLE_RATE :Number = 44100;
	public static const BUFFER_SIZE :int = 2048;	// mono size, not stereo, so less than 4096 plz
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function AudioPlayer() {
		super();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _isActive :Boolean;
	private var _sound :Sound;
	private var _chan :SoundChannel;
	
	private var _seq :FormantSequence;
	private var _frame :int;
	private var _samplesInFrame :int;
	private var _pitchPhase :Number;	// One cycle is range: 0..2*Math.PI
	private var _pitchInc :Number;	// Pitch phase increment. Added to _pitchPhase every frame, to oscillate the pitch.
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function play() :void {
		_isActive = true;
		
		// If the sound is not playing, then start it
		if( !_sound ) {
			_sound = new Sound();
			// Stops dispatching unless the event listener is a strong link. Weird
			_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
			
			_chan = _sound.play(0,0);
			_chan.addEventListener( Event.SOUND_COMPLETE, soundComplete, false, 0, true );
		}
	}
	
	public function stop() :void {
		_isActive = false;
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private var zzz :Number = 0;
	
	private function sampleData( e:SampleDataEvent ) :void {
		if( !_isActive ) return;	// Let the SampleDataEvent return with no data
		
		//if(DEBUG) trace("Sample data!", e.position);
		for( var i:int=0; i < BUFFER_SIZE; i++ ) {
			zzz += 440.0*2*Math.PI / SAMPLE_RATE;
			var out:Number = Math.sin( zzz );
			
			// Write to the sound buffer
			e.data.writeFloat( out );	// left channel
			e.data.writeFloat( out );	// right channel
		}
	}
	
	private function soundComplete( e:Event ) :void {
		trace("Sound complete!");
		if( _sound ) {
			_sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
		}
		_sound = null;
		_chan = null;
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

