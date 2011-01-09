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
	
	private var _hasEverPlayed :Boolean = false;
	private var _seq :FormantSequence;
	private var _frame :int = 0;
	private var _samplesInFrame :Number = 0;
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
		
		// First time playing? Then immediately set the freq/amp/etc of all the voices
		if( !_hasEverPlayed ) {
			_hasEverPlayed = true;
			
			for( i=0; i<_voiced.length; i++ ) {
				_voiced[i].playFrame( _seq.voiced(i).frame(_frame), 1.0, true );
			}
			
			for( i=0; i<_unvoiced.length; i++ ) {
				_unvoiced[i].playFrame( _seq.unvoiced(i).frame(_frame), 1.0, true );
			}
			
			_pitchInc = _seq.pitch().frame(_frame).freq * ((2*Math.PI) / SAMPLE_RATE);
		}
		
		//if(DEBUG) trace("Sample data!", e.position);
		for( i=0; i < BUFFER_SIZE; i++ ) {
			_samplesInFrame++;
			if( _samplesInFrame > _seq.samplesPerFrame ) {
				_samplesInFrame -= _seq.samplesPerFrame;
				_frame = (_frame+1) % FormantSequence.FRAMES;	// Advance to next frame
				
				_pitchInc = _seq.pitch().frame(_frame).freq * ((2*Math.PI) / SAMPLE_RATE);
				
				// Tell all audio voices to play the new frame
				var o:int;
				for( v=0; v<_voiced.length; v++ ) {
					_voiced[v].playFrame( _seq.voiced(v).frame(_frame), 1.0 );
				}
				for( v=0; v<_unvoiced.length; v++ ) {
					_unvoiced[v].playFrame( _seq.unvoiced(v).frame(_frame), 1.0 );
				}
			}
			
			// Increment the pitch
			_pitchPhase += _pitchInc;
			if( _pitchPhase > 2*Math.PI ) {
				_pitchPhase -= 2*Math.PI;
				// Voiced formants rely on knowing when the pitch phase flips around from 2*PI back to 0.
				_isResetSync = true;
			} else {
				_isResetSync = false;
			}

			// Gather the samples
			var out:Number = 0;
			for( v=0; v<FormantSequence.VOICED_OPS; v++ ) {
				out += _voiced[v].getSample( _pitchPhase, _isResetSync );
			}
			for( v=0; v<FormantSequence.UNVOICED_OPS; v++ ) {
				out += _unvoiced[v].getSample( _pitchPhase, _isResetSync );
			}
			
			// Volume adjust
			out *= (1.0/8);
			
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

