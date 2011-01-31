package fseq.model {

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
import fseq.audio.*;

public class FormantSequence extends Object
{
	//--------------------------------------
	// CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//  CONSTRUCTOR
	//--------------------------------------
	public function FormantSequence( inPitch:Operator=null, inVoiced:Vector.<Operator>=null, inUnvoiced:Vector.<Operator>=null ) {
		super();
		
		if( inPitch ) {
			_pitch = inPitch;
		} else {
			_pitch = new Operator();	// empty
		}
		
		if( inVoiced ) {
			_voiced = inVoiced;
		} else {
			_voiced = new Vector.<Operator>();
			for( var v:int=0; v<Const.VOICED_OPS; v++ ) {
				_voiced.push( new Operator() );
			}
		}

		if( inUnvoiced ) {
			_unvoiced = inUnvoiced;
		} else {
			_unvoiced = new Vector.<Operator>();
			for( var u:int=0; u<Const.UNVOICED_OPS; u++ ) {
				_unvoiced.push( new Operator() );
			}
		}
	}
	
	public function initWithBytes( pitchBytes:Vector.<uint>, voicedFreqAr:Array, voicedLevelAr:Array, unvoicedFreqAr:Array, unvoicedLevelAr:Array ) :void {
		for( var f:int=0; f<pitchBytes.length; f++ ) {
			_pitch.frame(f).freq = OperatorFrame.syxToFreq( pitchBytes[f] );
			
			var op:int;
			for( op=0; op<8; op++ ) {
				_voiced[op].frame(f).freq = OperatorFrame.syxToFreq( voicedFreqAr[op][f] );
				_voiced[op].frame(f).amp = OperatorFrame.syxToAmp( voicedLevelAr[op][f] );
				_unvoiced[op].frame(f).freq = OperatorFrame.syxToFreq( unvoicedFreqAr[op][f] );
				_unvoiced[op].frame(f).amp = OperatorFrame.syxToAmp( unvoicedLevelAr[op][f] );
			}
		}
	}
	
	//--------------------------------------
	//  PRIVATE VARIABLES
	//--------------------------------------
	private var _pitch :Operator;	// Disregards its own amplitude
	private var _voiced :Vector.<Operator>;
	private var _unvoiced :Vector.<Operator>;
	public var tempoAdjust :Number = 1.0;

	public var title :String = "Untitled";
	public var loopStart :int = 0;
	public var loopEnd :int = 511;
	public var loopMode :String = Const.ONE_WAY;
	public var speedAdjust :int = 26;
	public var velSensitivity :int = 0;
	public var pitchMode :String = Const.FSEQ_PITCH;
	public var noteAssign :int = 54;
	public var pitchTuning :int = 63;
	public var seqDelay :int = 0;
	
	//--------------------------------------
	//  GETTER/SETTERS
	//--------------------------------------
	public function get samplesPerFrame() :Number {
		// TODO: Needs a real value based on speed adjustment
		return (Const.SAMPLE_RATE / 100.0) * tempoAdjust;
	}
	
	//--------------------------------------
	//  PUBLIC METHODS
	//--------------------------------------
	public function pitch() :Operator { return _pitch; }
	public function voiced( id:int ) :Operator { return _voiced[id]; }
	public function unvoiced( id:int ) :Operator { return _unvoiced[id]; }

	public function clone() :FormantSequence {
		// Duplicate the pitch
		var pitchClone:Operator = _pitch.clone();

		var o:int;
		
		// Duplicate the voiced operators
		var vClone:Vector.<Operator> = new Vector.<Operator>();
		for( o=0; o<Const.VOICED_OPS; o++ ) {
			vClone.push( _voiced[o].clone() );
		}
		
		// Duplicate the unvoiced operators
		var uClone:Vector.<Operator> = new Vector.<Operator>();
		for( o=0; o<Const.UNVOICED_OPS; o++ ) {
			uClone.push( _unvoiced[o].clone() );
		}
		
		var out:FormantSequence = new FormantSequence( pitchClone, vClone, uClone );
		out.tempoAdjust = tempoAdjust;
		return out;
	}
	
	public function normalize() :void {
		var f:int, op:int;
		var VOperator:Operator, UOperator:Operator;
		
		// Find the maximum power
		var maxAmp:Number = 0;
		for( op=0; op<Const.VOICED_OPS; op++ ) {
			VOperator = voiced(op);
			UOperator = unvoiced(op);
			for( f=0; f<Const.FRAMES; f++ ) {
				maxAmp = Math.max( maxAmp, VOperator.frame(f).amp, UOperator.frame(f).amp );
			}
		}
		
		// Silly optimization: If the max amp is already 1.0, don't normalize ;)
		if( maxAmp != 1.0 ) {
			var ampMult:Number = 1.0/maxAmp;
			for( op=0; op<Const.VOICED_OPS; op++ ) {
				VOperator = voiced(op);
				UOperator = unvoiced(op);
				for( f=0; f<Const.FRAMES; f++ ) {
					VOperator.frame(f).amp *= ampMult;
					UOperator.frame(f).amp *= ampMult;
				}
			}
		}
	}
	
	//--------------------------------------
	//  EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//  PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}

