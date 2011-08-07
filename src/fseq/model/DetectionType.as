package fseq.model
{

public class DetectionType extends Object
{
	
	public static const FORMANTS_ORIGINAL_METHOD :String = "Formants, crusty original method";
	public static const FORMANTS_NONE :String = "Formants, no smoothing";
	public static const FORMANTS_LIGHT :String = "Formants, light smoothing";
	public static const FORMANTS_MEDIUM :String = "Formants, medium smoothing";
	public static const FORMANTS_HEAVY :String = "Formants, heavy smoothing";
	public static const VOCODER :String = "Vocoder";
	public static const ALL_FORMANT_DETECTORS :Array = [FORMANTS_ORIGINAL_METHOD,FORMANTS_NONE,FORMANTS_LIGHT,FORMANTS_MEDIUM,FORMANTS_HEAVY,VOCODER];
	
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
	
}

}

