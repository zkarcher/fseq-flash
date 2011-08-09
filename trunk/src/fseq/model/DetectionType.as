package fseq.model
{

public class DetectionType extends Object
{
	
	public static const FORMANTS_ORIGINAL_METHOD :String = "Formants, crusty original method";
	public static const FORMANTS_NONE :String = "Formants, no smoothing";
	public static const FORMANTS_LIGHT :String = "Formants, light smoothing";
	public static const FORMANTS_MEDIUM :String = "Formants, medium smoothing";
	public static const FORMANTS_HEAVY :String = "Formants, heavy smoothing";
	public static const VOCODER_NARROW :String = "Vocoder, narrow bands";
	public static const VOCODER_MEDIUM :String = "Vocoder, medium bands";
	public static const VOCODER_WIDE :String = "Vocoder, wide bands";
	public static const ALL_FORMANT_DETECTORS :Array = [
							FORMANTS_ORIGINAL_METHOD,
							FORMANTS_NONE, FORMANTS_LIGHT, FORMANTS_MEDIUM, FORMANTS_HEAVY,
							VOCODER_NARROW, VOCODER_MEDIUM, VOCODER_WIDE
						];
	
	public function DetectionType()
	{
		super();
	}
	
	public static function smoothness( type:String ) :int {
		switch( type ) {
			case FORMANTS_NONE:	return 0;
			case FORMANTS_LIGHT: return 1;
			case FORMANTS_MEDIUM: return 2;
			case FORMANTS_HEAVY: return 5;
		}
		return 0;
	}
	
	public static function isVocoder( type:String ) :Boolean {
		switch( type ) {
			case VOCODER_NARROW:
			case VOCODER_MEDIUM:
			case VOCODER_WIDE:
				return true;
		}
		return false;
	}
	
	// 1.0 == 1 octave up, and 1 octave down
	public static function vocoderBandWidth( type:String ) :Number {
		switch( type ) {
			case VOCODER_NARROW:	return 0.1;
			case VOCODER_MEDIUM:	return 0.25;
			case VOCODER_WIDE:		return 0.5;
		}
		return 0;
	}
}

}

