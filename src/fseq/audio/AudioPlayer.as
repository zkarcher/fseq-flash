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
	public static const BUFFER_SIZE :int = 4096;	// mono size, not stereo, so less than 4096 plz
	
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
	
	private var _buffer :Vector.<Number>;
	private var _pitchPhases :Vector.<Number>;
	private var _resetSyncs :Vector.<Boolean>;
	private var _setFrameIds :Vector.<int>;
	
	private var _seq :FormantSequence;
	private var _frame :int = 0;
	private var _samplesInFrame :Number = 999999;	// Force a new frame to become active
	private var _pitchPhase :Number = 0;	// One cycle is range: 0..2*Math.PI
	private var _pitchInc :Number = 0;	// Pitch phase increment. Added to _pitchPhase every frame, to oscillate the pitch.
	private var _isResetSync :Boolean = true;
	
	private var _voiced :Vector.<VoicedAudio>;
	private var _unvoiced :Vector.<UnvoicedAudio>;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function play( inSeq:FormantSequence ) :void {
		_isActive = true;
		_seq = inSeq;
		
		if( !_buffer || !_pitchPhases || !_resetSyncs || !_setFrameIds ) {
			_buffer = new Vector.<Number>(BUFFER_SIZE, true);
			_pitchPhases = new Vector.<Number>(BUFFER_SIZE, true);
			_resetSyncs = new Vector.<Boolean>(BUFFER_SIZE, true);
			_setFrameIds = new Vector.<int>(BUFFER_SIZE, true );
		}
		
		// Create Voiced & Unvoiced audio layers
		if( !_voiced || !_unvoiced ) {
			_voiced = new Vector.<VoicedAudio>();
			for( var v:int=0; v<FormantSequence.VOICED_OPS; v++ ) {
				_voiced.push( new VoicedAudio() );
			}
			_unvoiced = new Vector.<UnvoicedAudio>();
			for( var u:int=0; u<FormantSequence.UNVOICED_OPS; u++ ) {
				_unvoiced.push( new UnvoicedAudio() );
			}
		}
		
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
	private function sampleData( e:SampleDataEvent ) :void {
		if( !_isActive ) return;	// Let the SampleDataEvent return with no data
		
		var i:int;
		var v:int;	// iterate over voiced & unvoiced
		
		//if(DEBUG) trace("Sample data!", e.position);
		
		// Fill our buffer vectors with info on the pitch phase, frames, etc
		for( i=0; i<BUFFER_SIZE; i++ ) {
			_buffer[i] = 0;	// clear the audio buffer
			
			// Determine when to advance to the next frame
			_samplesInFrame++;
			if( _samplesInFrame > _seq.samplesPerFrame ) {
				_samplesInFrame -= _seq.samplesPerFrame;

				_frame = (_frame+1) % FormantSequence.FRAMES;	// Advance to next frame
				_setFrameIds[i] = _frame;
				
				_pitchInc = _seq.pitch().frame(_frame).freq * ((2*Math.PI) / SAMPLE_RATE);
				
			} else {
				_setFrameIds[i] = -1;
			}
			
			// Increment the pitch
			_pitchPhase += _pitchInc;
			_pitchPhases[i] = _pitchPhase;	// Pass the pitch phases to the voices
			
			// Pitch phase rolls over from 2*Math.PI back to 0.
			// Voiced formants rely on knowing when the pitch phase flips around from 2*PI back to 0.
			if( _pitchPhase > 2*Math.PI ) {
				_pitchPhase -= 2*Math.PI;
				_resetSyncs[i] = true;
			} else {
				_resetSyncs[i] = false;
			}
		}
		
		// Now that we've prepared our various Vectors, we tell each voice to add sounds to the buffer using
		// all this info.
		for( i=0; i<FormantSequence.VOICED_OPS; i++ ) {
			_voiced[i].addSamples( _buffer, _pitchPhases, _resetSyncs, _setFrameIds, _seq.voiced(i) );
		}
		for( i=0; i<FormantSequence.UNVOICED_OPS; i++ ) {
			_unvoiced[i].addSamples( _buffer, _pitchPhases, _resetSyncs, _setFrameIds, _seq.unvoiced(i) );
		}
		
		// Now we can create the final audio
		for( i=0; i<BUFFER_SIZE; i++ ) {
			// Volume adjust
			var out:Number = _buffer[i] / 16;

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

