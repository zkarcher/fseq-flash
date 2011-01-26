package dsp;

import java.util.Random;

class SignalGenerator {

  private String wform = "None";
  private float ampl = 1.0f;
  private float rate = 8000.0f;
  private float freq = 1000.0f;
  private float dcLevel = 0.0f;
  private float noise = 0.0f;
  private int nSamples = 256;
  private boolean addDCLevel = false;
  private boolean addNoise = false;

  public void setWaveform(String w) {
    wform = w;
  }

  public String getWaveform() {
    return wform;
  }

  public void setAmplitude(float a) {
    ampl = a;
  }

  public float getAmplitude() {
    return ampl;
  }

  public void setFrequency(float f) {
    freq = f;
  }

  public float getFrequency() {
    return freq;
  }

  public void setSamplingRate(float r) {
    rate = r;
  }

  public float getSamplingRate() {
    return rate;
  }

  public void setSamples(int s) {
    nSamples = s;
  }

  public int getSamples() {
    return nSamples;
  }

  public void setDCLevel(float dc) {
    dcLevel = dc;
  }

  public float getDCLevel() {
    return dcLevel;
  }

  public void setNoise(float n) {
    noise = n;
  }

  public float getNoise() {
    return noise;
  }

  public void setDCLevelState(boolean s) {
    addDCLevel = s;
  }

  public boolean isDCLevel() {
    return addDCLevel;
  }

  public void setNoiseState(boolean s) {
    addNoise = s;
  }

  public boolean isNoise() {
    return addNoise;
  }

  public float[] generate() {

    float[] values = new float[nSamples];

    if (wform.equals("Sine")) {  // sine wave
      float theta = 2.0f * (float) Math.PI * freq / rate;
      for (int i = 0; i < nSamples; i++)
        values[i] = ampl * (float) Math.sin(i*theta);
    }

    if (wform.equals("Cosine")) {  // cosine wave
      float theta = 2.0f * (float) Math.PI * freq / rate;
      for (int i = 0; i < nSamples; i++)
        values[i] = ampl * (float) Math.cos(i*theta);
    }

    if(wform.equals("Square")) { // square wave
      float p = 2.0f * freq / rate;
      for (int i = 0; i < nSamples; i++)
        values[i] = Math.round(i*p) % 2  == 0 ?  ampl : -ampl;
    }

    if(wform.equals("Triangular")) { // triangular wave
      float p = 2.0f * freq / rate;
      for (int i = 0; i < nSamples; i++) {
        int ip = Math.round(i*p);
        values[i] = 2.0f*ampl*(1 - 2*(ip % 2)) * (i*p - ip);
      }
    }

    if(wform.equals("Sawtooth")) { // sawtooth wave
      for (int i = 0; i < nSamples; i++) {
        float q = i*freq/rate;
        values[i] = 2.0f*ampl*(q - Math.round(q));
      }
    }

    if (addDCLevel) {  // add constant DC level to signal
      for (int i = 0; i < nSamples; i++)
	      values[i] += dcLevel;
    }

    if (addNoise) {  // add random "noise" to signal
      Random r = new Random();
      for (int i = 0; i < nSamples; i++)
	      values[i] += noise * r.nextGaussian();
    }

    return values;
  }
}
