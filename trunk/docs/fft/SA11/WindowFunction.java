package dsp;

public class WindowFunction {

  public static final int RECTANGULAR  = 0;
  public static final int BARTLETT     = 1;
  public static final int HANNING      = 2;
  public static final int HAMMING      = 3;
  public static final int BLACKMAN     = 4;
  public static final int KAISER       = 5;

  int windowType = 0;  // defaults to rectangular window

  public WindowFunction() {
  }

  public void setWindowType(int wt) {
    windowType = wt;
  }

  public void setWindowType(String w) {
    if (w.equals("Rectangular")) windowType = RECTANGULAR;
    if (w.equals("Bartlett"))    windowType = BARTLETT;
    if (w.equals("Hanning"))     windowType = HANNING;
    if (w.equals("Hamming"))     windowType = HAMMING;
    if (w.equals("Blackman"))    windowType = BLACKMAN;
  }

  public int getWindowType() {
    return windowType;
  }

  public float[] generate(int nSamples) {
    // generate nSamples window function values
    // for index values 0 .. nSamples - 1
    int m = nSamples/2;
    float r;
    float pi = (float)Math.PI;
    float[] w = new float[nSamples];
    switch (windowType) {
      case BARTLETT: // Bartlett (triangular) window
        for (int n = 0; n < nSamples; n++)
          w[n] = 1.0f - (float)Math.abs(n - m)/m;
        break;
      case HANNING: // Hanning window
        r = pi/(m+1);
        for (int n = -m; n < m; n++)
          w[m + n] = 0.5f + 0.5f*(float)Math.cos(n*r);
        break;
      case HAMMING: // Hamming window
        r = pi/m;
        for (int n = -m; n < m; n++)
          w[m + n] = 0.54f + 0.46f*(float)Math.cos(n*r);
        break;
      case BLACKMAN: // Blackman window
        r = pi/m;
        for (int n = -m; n < m; n++)
          w[m + n] = 0.42f + 0.5f*(float)Math.cos(n*r)
                      + 0.08f*(float)Math.cos(2*n*r);
        break;
      default: // Rectangular window function
        for (int n = 0; n < nSamples; n++) w[n] = 1.0f;
    }
    return w;
  }
}