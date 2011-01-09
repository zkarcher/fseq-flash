package fseq {

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

public class AudioPlayer extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	public static const SAMPLE_RATE :Number = 44100;
	public static const BUFFER_SIZE :int = 2048;
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function AudioPlayer() {
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _sound :Sound;
	private var _chan :SoundChannel;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function play() :void {
		// If the sound is not playing, then start it
		/*
		if( !_sound ) {
			_sound = new Sound();
			// Stops dispatching unless the event listener is a strong link. Weird
			_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
			
			_chan = _sound.play(0,0);
			_chan.addEventListener( Event.SOUND_COMPLETE, soundComplete, false, 0, true );			
		}
		*/
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function sampleData( e:SampleDataEvent ) :void {
		/*
		if(DEBUG) trace("Sample data!", e.position);

		if( _scopeData ) {	// TESTING
			_scopeData.fillRect( _scopeData.rect, 0x000000 );
		}

		var fmt:Formant;		
		for( var i:int=0; i < STEREO_BUFFER_SIZE; i++ ) {			
			// Do we need to update the envelopes?
			if( (_samples % ENVELOPE_UPDATE_TIME) == 0 ) {
				var progress:Number = Number(_samples) / _play.totalSamples;
				for each( fmt in _formants ) {
					fmt.setProgress( progress );
				}
				_play.lfoFreq.setProgress( progress );
				_play.lfoWeight.setProgress( progress );
				_lfo.freq = lfoFreq.value;
			}
			
			_lfo.tick();
			var lfoValue:Number = _lfo.sine();
			// Shape the lfoValue's waveform
			if( _play.lfoWeight.value ) {
				lfoValue = (lfoValue+1.0)/2.0;
				lfoValue = Math.pow( lfoValue, _play.lfoWeight.twoPower );
				lfoValue = (lfoValue*2.0)-1.0;
			}
			
			// Process each formant, add to the total output for this sample
			var out:Number = 0.0;
			for each( fmt in _formants ) {
				out += fmt.tickAndReturnValue( lfoValue );
			}
			
			// Write to the sound buffer
			e.data.writeFloat( out * VOLUME );	// left channel
			e.data.writeFloat( out * VOLUME );	// right channel
			
			_samples++;
			if( _samples >= totalSamples ) {	// Is this sound exhausted?
				// Pack the rest of it with 0's, to avoid range errors (invalid sample data length.)
				for( var j:int=i+1; j<STEREO_BUFFER_SIZE; j++ ) {
					e.data.writeFloat(0.0);	// left channel
					e.data.writeFloat(0.0);	// right channel
				}
				_sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
				return;
			}
			
			if( _scopeData ) {
				if( i < _scopeData.width ) {
					_scopeData.setPixel( i, (out+1.0)*100.0, 0xffffff );
				}
			}
		}
		*/
	}
	
	private function soundComplete( e:Event ) :void {
		/*
		if(DEBUG) trace("Sound complete");
		_sound = null;
		_chan = null;
		*/
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

