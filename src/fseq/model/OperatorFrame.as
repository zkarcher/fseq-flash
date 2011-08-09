package fseq.model
{

import com.zacharcher.math.*;

public class OperatorFrame extends Object
{
	
	private static const HIGHEST_FREQ_EXP :Number = 14.302;
	private static const HIGHEST_FREQ :Number = Math.pow( 2.0, HIGHEST_FREQ_EXP );
	private static const AMP_STEPS_PER_6DB :Number = 8.5;
	
	public function OperatorFrame( inAmp:Number, inFreq:Number )
	{
		super();
		amp = inAmp;
		freq = inFreq;
	}
	
	private var _amp :Number;
	public function get amp() :Number { return _amp; }
	public function set amp( n:Number ) :void {
		_amp = Math.max( 0, n );
	}
	
	private var _freq :Number;
	public function get freq() :Number { return _freq; }
	public function set freq( n:Number ) :void {
		_freq = Math.max( n, 1.0 );	// Never set below 1 hz :P
	}
	
	public static function syxToFreq( syx:uint ) :Number {
		// Reverse-engineered after a little hacking.
		// The frequencies probably aren't perfect yet.
		//return Math.pow( 2.0, (14.302 - (0.001879 * (0x3fff - syx))) );
		
		// Inferred from RndArp1.syx. There's a high note that is 1 octave above a lower root note.
		// The syx freq numbers are approx. 13040, 13554. It's probably 512 steps per octave, then?
		return Math.pow( 2.0, (HIGHEST_FREQ_EXP - ((1.0/512.0) * (0x3fff-syx))) );
	}
	
	// Returns a 14-bit integer. Not spliced at the 8th bit, so perform the bit shifting outside of this function.
	public function freqToSyx() :int {
		// Convert the freq back to a 14-bit integer.
		// Get the lg() of freq, then subtract the result from HIGHEST_FREQ_EXP
		var lg:Number = Num.lg( freq );
		var diff:Number = HIGHEST_FREQ_EXP - lg;
		return int( Num.dither( 0x3fff - (diff * 512.0) ) );
	}
	
	public static function syxToAmp( syx:uint ) :Number {
		// 7-bit number. Convert to db.
		// How is it measured, 6 db steps for each 50% attenuation? 8.5 steps?
		// The syx values are inverted: 0 has the greatest amplitude, 0x7f the least.
		var inPow:Number = Math.pow( 2.0, Number(0x7f-syx) / AMP_STEPS_PER_6DB );
		var maxPow:Number = Math.pow( 2.0, Number(0x7f) / AMP_STEPS_PER_6DB );
		return inPow / maxPow;
	}
	public function ampToSyx() :int {
		// Calculate the number of 6db drops using a log function.
		// 1.0amp => 0 log drops.
		var logDrops:Number = Num.lg( 1.0 / Math.max(0.000001,amp) );	// no divide by zero
		return int( Math.max( 0x0, Math.min( 0x7f, (logDrops * AMP_STEPS_PER_6DB) )));	 // sane values only plz
	}
	
	public function clone() :OperatorFrame {
		return new OperatorFrame( amp, freq );
	}
}

}

