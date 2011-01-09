package fseq.model
{

public class OperatorFrame extends Object
{
	
	public function OperatorFrame( inAmp:Number, inSemitone:Number )
	{
		super();
		amp = inAmp;
		semitone = inSemitone;
	}
	
	public var amp :Number;
	public var semitone :Number;
	
	// Convert semitone number to hertz
	public function get freq() :Number {
		// TODO This formula is wrong, should mimic the FS1R. Need to reverse-engineer that
		return Math.pow( 2.0, semitone*(1.0/12.0) ) * 55.0; 
	}
	
	public function clone() :OperatorFrame {
		return new OperatorFrame( amp, semitone );
	}
}

}

