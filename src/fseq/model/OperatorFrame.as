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
		return 0;	// TODO
	}
	
	public function clone() :OperatorFrame {
		return new OperatorFrame( amp, semitone );
	}
}

}

