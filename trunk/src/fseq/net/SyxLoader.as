package fseq.net {

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
import flash.net.*;
import flash.utils.*;
import caurina.transitions.Tweener;
import com.zacharcher.color.*;
import com.zacharcher.math.*;
import fseq.controller.*;
import fseq.events.*;
import fseq.model.*;
import fseq.net.*;

public class SyxLoader extends BaseLoader
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function SyxLoader() {
		super();
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _seq :FormantSequence;
	private var _file :FileReference;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get formantSequence() :FormantSequence { return _seq; }
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function loadFile() :void {
		_file = new FileReference();
		_file.addEventListener( Event.SELECT, fileSelected, false, 0, true );
		_file.addEventListener( Event.COMPLETE, fileReferenceLoaded, false, 0, true );
		var filter:FileFilter = new FileFilter("SysEx files","*.syx");
		_file.browse( [filter] );
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	private function fileSelected( e:Event ) :void {
		_file.load();
	}
	
	private function fileReferenceLoaded( e:Event ) :void {
		readByteArray( _file.data );
	}
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	protected override function handleLoaderComplete() :void {
		readByteArray( _urlLoader.data );
	}
	
	private function readByteArray( ba:ByteArray ) :void {
		var i:int;
		
		ba.position = 0;
		
		// This file format is specified in the FS1RE2.PDF file available on the intertubes
		// See page 37 for the header.
		// See page 40 for the Fseq parameters.
		// Also, examining .syx files with hex editors helped a lot.
		
		assertEquals( ba.readUnsignedByte(), 0xf0, "Exclusive Status" );
		assertEquals( ba.readUnsignedByte(), 0x43, "Yamaha ID" );

		var deviceNumber:uint = ba.readUnsignedByte();
		trace("Device number:", deviceNumber);

		assertEquals( ba.readUnsignedByte(), 0x5e, "Model ID" );

		var expectedByteCount:uint = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();

		var address:uint = (((ba.readUnsignedByte() << 7) | ba.readUnsignedByte()) << 7) | ba.readUnsignedByte();	// 21-bit number
		
		// The next 8 bytes are the name, in ASCII format
		var title:String = ba.readUTFBytes( 8 );
		trace("title is", title);
		
		// The next 8 bytes are "reserved", so they're unimportant to us
		ba.position += 8;
		
		var loopStart :uint = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();	// 00-7F each
		var loopEnd :uint = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();	// 00-7F each
		
		// ShoobyDoo has silent frames after the loopEnd (498)
		trace("Loop start:", loopStart, "/ Loop end:", loopEnd);

		var loopMode :uint = ba.readUnsignedByte();	// 0:one way, 1:round
		var speedAdjust :uint = ba.readUnsignedByte();	// 00-7F
		var velSensitivity :uint = ba.readUnsignedByte();	// 00-07
		var pitchMode :uint = ba.readUnsignedByte();	// 0:pitch, 1:non-pitch
		var noteAssign :uint = ba.readUnsignedByte();	// 00-7F
		var pitchTuning :uint = ba.readUnsignedByte();	// 00-7F, corresponds to -63..63
		var seqDelay :uint = ba.readUnsignedByte();	// "00-63" (is this actually 00-3F?)
		var dataFormat :uint = ba.readUnsignedByte();	// 00-03, corresponds to 128,256,384,512 frames
		
		// The next two bynes are reserved, skip them
		ba.position += 2;
		
		var validDataEndStep :uint = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();	// 00-7F each
		
		// Now it's time to read the frames.
		var totalFrames:int = (dataFormat+1) * 128;
		trace("Total incoming frames:", totalFrames);
		
		// We'll store the frame values in these Vectors:
		var pitch:Vector.<uint> = new Vector.<uint>( Const.FRAMES, true );
		var voicedFreq:Array = [];
		var voicedLevel:Array = [];
		var unvoicedFreq:Array = [];
		var unvoicedLevel:Array = [];
		// Create a vector for each voiced/unvoiced operator
		for( var v:int=0; v<8; v++ ) {
			voicedFreq.push( new Vector.<uint>( Const.FRAMES, true ));
			voicedLevel.push( new Vector.<uint>( Const.FRAMES, true ));
			unvoicedFreq.push( new Vector.<uint>( Const.FRAMES, true ));
			unvoicedLevel.push( new Vector.<uint>( Const.FRAMES, true ));
		}
		
		// We will always expand sequences out to 512 frames, as faithfully as possible to the originals.
		// Since the original sequences are sometimes shorter than 512 frames long, we'll set more frames than
		// we'll load. (A loaded sequence with 128 frames will set 4 frames for each 1 frame loaded.)
		var setFrame:int = 0;	// Increment as we set each frame
		
		for( var f:int=0; f<totalFrames; f++ ) {
			// Read the pitch
			pitch[setFrame] = (ba.readUnsignedByte() << 7) | ba.readUnsignedByte();	// Two 7-bit bytes, make a 14-bit word
			//trace("Got pitch:", pitch[setFrame]);
			
			// voiced freqs: high bytes first
			var hi1:uint, lo1:uint;
			for( i=0; i<Const.VOICED_OPS; i++ ) { 
				var hibyte:uint = ba.readUnsignedByte();
				if( i==0 ) hi1 = hibyte;
				voicedFreq[i][setFrame] = hibyte << 7;	// 00-7F
			}
			// voiced freqs: low bytes
			for( i=0; i<Const.VOICED_OPS; i++ ) {
				var lobyte:uint = ba.readUnsignedByte();
				if( i==0 ) lo1 = lobyte;
				voicedFreq[i][setFrame] |= lobyte;	// 00-7F
			}
			
			// Lowest value is apparently 8933 (0x22e5), hmmm....
			//trace("ShoobyDo lowest voiced freq:", voicedFreq[0][f].toString(16));
			//trace("hi&lo:", hi1.toString(16), lo1.toString(16), "... V1 freq:", voicedFreq[0][f], "==", voicedFreq[0][f].toString(16));
			
			// voiced level
			for( i=0; i<Const.VOICED_OPS; i++ ) {
				voicedLevel[i][setFrame] = ba.readUnsignedByte();	// 00-7F
			}
			
			// unvoiced freqs: high bytes first
			for( i=0; i<Const.UNVOICED_OPS; i++ ) { 
				unvoicedFreq[i][setFrame] = ba.readUnsignedByte() << 7;	// 00-7F
			}
			// unvoiced freqs: low bytes
			for( i=0; i<Const.UNVOICED_OPS; i++ ) {
				unvoicedFreq[i][setFrame] |= ba.readUnsignedByte();	// 00-7F
			}
			// unvoiced level
			for( i=0; i<Const.UNVOICED_OPS; i++ ) {
				unvoicedLevel[i][setFrame] = ba.readUnsignedByte();	// 00-7F
			}
			
			setFrame++;	// Always increment at least one frame
			var dupeFrames:int = 0;
			switch( totalFrames ) {
				case 512:
					// No padding needed.
					break;
				case 384:
					// TODO: It would be nice to interpolate some frames or something
					if( (f%3) == 2 ) dupeFrames = 1;
					break;
				case 256:
					dupeFrames = 1;
					break;
				case 128:
					dupeFrames = 3;
					break;
			}
			
			// If we are loading less than 512 frames, some of the loaded frames need to be duplicated to fill
			// all 512 frames of our FormantSequence.
			for( var d:int=0; d<dupeFrames; d++ ) {
				pitch[setFrame] = pitch[setFrame-1];
				for( i=0; i<Const.VOICED_OPS; i++ ) {
					voicedFreq[i][setFrame] = voicedFreq[i][setFrame-1];
					voicedLevel[i][setFrame] = voicedLevel[i][setFrame-1];
				}
				for( i=0; i<Const.UNVOICED_OPS; i++ ) {
					unvoicedFreq[i][setFrame] = unvoicedFreq[i][setFrame-1];
					unvoicedLevel[i][setFrame] = unvoicedLevel[i][setFrame-1];
				}
				setFrame++;
			}
		}
		
		var expectedChecksum :uint = ba.readUnsignedByte();
		//var checksum :uint = byteCount + address + OTHER STUFF;
		
		assertEquals( ba.readUnsignedByte(), 0xF7, "End of exclusive data" );
		
		var bytesRead:uint = ba.position;
		assertEquals( bytesRead, expectedByteCount, "Bytes read vs expected byte count" );
		// TODO: Why don't these match?...
		
		// Now let's evaluate that checksum
		ba.position = 4;
		var check:uint = 0x0;
		// Don't read the "end of exclusive data" byte
		for( var b:int=4; b<bytesRead-1; b++ ) {
			check += ba.readUnsignedByte();
		}
		assertEquals( check & 0x7f, 0x0, "Low 7 bytes of checksum should be zero" );
		
		// Make a formant sequence with this stuff
		_seq = new FormantSequence();
		_seq.initWithBytes( pitch, voicedFreq, voicedLevel, unvoicedFreq, unvoicedLevel );
		_seq.tempoAdjust = Math.max( totalFrames / 512.0, 0.4 );
		_seq.title = title;
		_seq.loopStart = loopStart;
		_seq.loopEnd = loopEnd;
		_seq.loopMode = (loopMode==0) ? Const.ONE_WAY : Const.ROUND;
		_seq.speedAdjust = speedAdjust;
		_seq.velSensitivity = velSensitivity;
		_seq.pitchMode = (pitchMode==0) ? Const.FSEQ_PITCH : Const.FREE_PITCH;
		_seq.noteAssign = noteAssign;
		_seq.pitchTuning = pitchTuning;
		_seq.seqDelay = seqDelay;
		
		dispatchEvent( new CustomEvent( CustomEvent.FSEQ_COMPLETE ));
	}
	
	private function assertEquals( a:uint, b:uint, description:String=null ) :uint {
		if( a != b ) {
			trace("** SyxLoader: failed assertion:", description, a, b);
		}
		return a;
	}
	
}

}

