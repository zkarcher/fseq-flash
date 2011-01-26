package dsp;

import java.awt.*;
import java.applet.Applet;
import java.awt.event.*;

public class Analyser extends Applet {

  float[] signal;
  float[] spectrum;
  int nSamples;
  float maxValue;
  boolean isValidSignal, isValidSpectrum;
  GraphPlot signalPlot = new GraphPlot();
  GraphPlot spectrumPlot = new GraphPlot();
  SignalGenerator sg = new SignalGenerator();
  WindowFunction wf = new WindowFunction();
  FastFourierTransform fft = new FastFourierTransform();
  AntiAliasFilter aaf = new AntiAliasFilter();
  Cursor curCrosshair = new Cursor(Cursor.CROSSHAIR_CURSOR);
  Panel pnlDisplay = new Panel();
  Panel pnlSignalPlot = new Panel();
  Panel pnlSpectrumPlot = new Panel();
  Panel pnlControls = new Panel();
  Panel pnlWaveform = new Panel();
  Panel pnlAddDCLevel = new Panel();
  Panel pnlFrequency = new Panel();
  Panel pnlAddNoise = new Panel();
  Panel pnlSamples = new Panel();
  Panel pnlFilter = new Panel();
  Panel pnlWindow = new Panel();
  Panel pnlCursor = new Panel();
  Label lblWaveform = new Label();
  Label lblFreq = new Label();
  Label lblFreqUnit = new Label();
  Label lblDCLevelUnit = new Label();
  Label lblSamples = new Label();
  Label lblNoiseUnit = new Label();
  Label lblWindow = new Label();
  Choice chWindow = new Choice();
  Choice chWaveform = new Choice();
  Choice chSamples = new Choice();
  TextField tfFreq = new TextField();
  TextField tfDCLevel = new TextField();
  TextField tfNoise = new TextField();
  Checkbox cbAddDCLevel = new Checkbox();
  Checkbox cbAddNoise = new Checkbox();
  GridLayout gridLayout1 = new GridLayout();
  FlowLayout flowLayout1 = new FlowLayout();
  FlowLayout flowLayout2 = new FlowLayout();
  FlowLayout flowLayout3 = new FlowLayout();
  FlowLayout flowLayout4 = new FlowLayout();
  FlowLayout flowLayout5 = new FlowLayout();
  FlowLayout flowLayout6 = new FlowLayout();
  FlowLayout flowLayout7 = new FlowLayout();
  FlowLayout flowLayout8 = new FlowLayout();
  BorderLayout borderLayout1 = new BorderLayout();
  BorderLayout borderLayout2 = new BorderLayout();
  BorderLayout borderLayout3 = new BorderLayout();
  CardLayout cardLayout1 = new CardLayout();
  Label lblX = new Label();
  Label lblY = new Label();
  Checkbox cbAntiAlias = new Checkbox();
  Panel pnlAmplitude = new Panel();
  FlowLayout flowLayout9 = new FlowLayout();
  Label lblAmpl = new Label();
  TextField tfAmpl = new TextField();
  Label lblAmplUnit = new Label();
  Panel pnlDomain = new Panel();
  Checkbox cbSignal = new Checkbox();
  FlowLayout flowLayout10 = new FlowLayout();
  Checkbox cbSpectrum = new Checkbox();
  CheckboxGroup cbgDomain = new CheckboxGroup();
  Button btnPlot = new Button();
  Label lblCursor = new Label();

  public Analyser() {
  }

  private Color strToColor(String s) {
    Color c = null;
    if (s != null) {
      if (s.equals("white"))     c = Color.white;
      if (s.equals("black"))     c = Color.black;
      if (s.equals("lightGray")) c = Color.lightGray;
      if (s.equals("gray"))      c = Color.gray;
      if (s.equals("darkGray"))  c = Color.darkGray;
      if (s.equals("red"))       c = Color.red;
      if (s.equals("green"))     c = Color.green;
      if (s.equals("blue"))      c = Color.blue;
      if (s.equals("yellow"))    c = Color.yellow;
      if (s.equals("magenta"))   c = Color.magenta;
      if (s.equals("cyan"))      c = Color.cyan;
      if (s.equals("pink"))      c = Color.pink;
      if (s.equals("orange"))    c = Color.orange;
    }
    return c;
  }

  public void init() {
    try {
      jbInit();
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void jbInit() throws Exception {
    this.setSize(new Dimension(600, 350));
    this.setLayout(borderLayout1);
    this.add(pnlDisplay, BorderLayout.CENTER);
    gridLayout1.setRows(5);
    gridLayout1.setColumns(2);
    flowLayout1.setAlignment(0);
    flowLayout2.setAlignment(0);
    flowLayout3.setAlignment(0);
    flowLayout4.setAlignment(0);
    flowLayout5.setAlignment(0);
    flowLayout6.setAlignment(0);
    flowLayout7.setAlignment(0);
    lblWindow.setText("Data window function:");
    chWindow.addItemListener(new Analyser_chWindow_itemAdapter(this));
    pnlDisplay.setLayout(cardLayout1);
    pnlSignalPlot.setLayout(borderLayout2);
    pnlSpectrumPlot.setLayout(borderLayout3);
    pnlSignalPlot.add(signalPlot);
    pnlSpectrumPlot.add(spectrumPlot);
    pnlDisplay.add(pnlSignalPlot, "signal");
    pnlDisplay.add(pnlSpectrumPlot, "spectrum");
    pnlDisplay.addMouseListener(new Analyser_pnlDisplay_mouseAdapter(this));
    pnlWindow.setLayout(flowLayout7);
    lblWaveform.setText("Waveform:  ");
    lblFreq.setText("Frequency: ");
    lblFreqUnit.setText("Hz");
    lblDCLevelUnit.setText("V");
    lblSamples.setText("Number of samples:  ");
    lblNoiseUnit.setText("V");
    chSamples.addItemListener(new Analyser_chSamples_itemAdapter(this));
    chWaveform.addItemListener(new Analyser_chWaveform_itemAdapter(this));
    tfFreq.setText("1000");
    tfFreq.setColumns(8);
    tfFreq.addTextListener(new Analyser_tfFreq_textAdapter(this));
    tfDCLevel.setText("0");
    tfDCLevel.setColumns(5);
    tfNoise.setText("0");
    tfNoise.setColumns(5);
    cbAddDCLevel.setLabel("DC level:");
    cbAddNoise.setLabel("Noise:    ");
    cbAddDCLevel.addItemListener(new Analyser_cbAddDCLevel_itemAdapter(this));
    cbAddNoise.addItemListener(new Analyser_cbAddNoise_itemAdapter(this));
    flowLayout8.setAlignment(0);
    lblX.setFont(new Font("Dialog", 1, 12));
    lblX.setBackground(SystemColor.controlLtHighlight);
    lblX.setText("                  ");
    lblY.setFont(new Font("Dialog", 1, 12));
    lblY.setBackground(SystemColor.controlLtHighlight);
    lblY.setText("                  ");
    cbAntiAlias.setLabel("Anti-aliasing filter");
    cbAntiAlias.addItemListener(new Analyser_cbAntiAlias_itemAdapter(this));
    flowLayout9.setAlignment(0);
    lblAmpl.setText("Amplitude:  ");
    tfAmpl.setText("1.0");
    tfAmpl.setColumns(5);
    tfAmpl.addTextListener(new Analyser_tfAmpl_textAdapter(this));
    lblAmplUnit.setText("V");
    cbSignal.setLabel("Signal");
    cbSignal.setCheckboxGroup(cbgDomain);
    flowLayout10.setAlignment(0);
    cbSignal.addItemListener(new Analyser_cbSignal_itemAdapter(this));
    cbSpectrum.setLabel("Spectrum");
    cbSpectrum.setCheckboxGroup(cbgDomain);
    cbSpectrum.addItemListener(new Analyser_cbSpectrum_itemAdapter(this));
    cbgDomain.setSelectedCheckbox(cbSignal);
    btnPlot.setLabel("   Plot   ");
    lblCursor.setText("Cursor values:");
    btnPlot.addActionListener(new Analyser_btnPlot_actionAdapter(this));
    pnlDomain.setLayout(flowLayout10);
    pnlAmplitude.setLayout(flowLayout9);
    pnlCursor.setLayout(flowLayout8);
    Color plColor = strToColor(getParameter("plcolor"));
    Color bgColor = strToColor(getParameter("bgcolor"));
    Color axColor = strToColor(getParameter("axcolor"));
    signalPlot.setPlotColor(plColor);
    signalPlot.setBgColor(bgColor);
    signalPlot.addMouseListener(new Analyser_signalPlot_mouseAdapter(this));
    signalPlot.setAxisColor(axColor);
    signalPlot.setCursor(curCrosshair);
    signalPlot.setPlotStyle(GraphPlot.SIGNAL);
    signalPlot.setTracePlot(true);
    signalPlot.addMouseMotionListener(new Analyser_signalPlot_mouseMotionAdapter(this));
    spectrumPlot.setPlotStyle(GraphPlot.SPECTRUM);
    spectrumPlot.setTracePlot(false);
    spectrumPlot.addMouseListener(new Analyser_spectrumPlot_mouseAdapter(this));
    spectrumPlot.addMouseMotionListener(new Analyser_spectrumPlot_mouseMotionAdapter(this));
    spectrumPlot.setPlotColor(plColor);
    spectrumPlot.setBackground(bgColor);
    spectrumPlot.setAxisColor(axColor);
    spectrumPlot.setCursor(curCrosshair);
    // Control panel
    pnlControls.setLayout(gridLayout1);
    this.add(pnlControls, BorderLayout.SOUTH);
    // Waveform selection
    pnlWaveform.setLayout(flowLayout1);
    chWaveform.addItem("Sine");
    chWaveform.addItem("Cosine");
    chWaveform.addItem("Square");
    chWaveform.addItem("Triangular");
    chWaveform.addItem("Sawtooth");
    chWaveform.select("Sine"); // default waveform
    pnlWaveform.add(lblWaveform);
    pnlWaveform.add(chWaveform);
    pnlControls.add(pnlWaveform);
    // Cursor values display
    pnlControls.add(pnlCursor, null);
    pnlCursor.add(lblCursor, null);
    pnlCursor.add(lblX, null);
    pnlCursor.add(lblY, null);
    // Amplitude setting
    pnlAmplitude.add(lblAmpl, null);
    pnlAmplitude.add(tfAmpl, null);
    pnlAmplitude.add(lblAmplUnit, null);
    pnlControls.add(pnlAmplitude, null);
    // Number of samples
    pnlSamples.setLayout(flowLayout5);
    chSamples.addItem("128");
    chSamples.addItem("256");
    chSamples.addItem("512");
    chSamples.addItem("1024");
    chSamples.select("256");
    pnlSamples.add(lblSamples);
    pnlSamples.add(chSamples);
    pnlControls.add(pnlSamples);
    // Signal frequency setting
    pnlFrequency.setLayout(flowLayout3);
    pnlFrequency.add(lblFreq);
    pnlFrequency.add(tfFreq);
    pnlFrequency.add(lblFreqUnit);
    pnlControls.add(pnlFrequency);
    // Window function setting
    chWindow.addItem("Rectangular");
    chWindow.addItem("Bartlett");
    chWindow.addItem("Hanning");
    chWindow.addItem("Hamming");
    chWindow.addItem("Blackman");
    pnlWindow.add(lblWindow, null);
    pnlWindow.add(chWindow);
    pnlControls.add(pnlWindow, null);
    // Added DC level setting
    pnlAddDCLevel.setLayout(flowLayout2);
    pnlAddDCLevel.add(cbAddDCLevel);
    pnlAddDCLevel.add(tfDCLevel);
    pnlAddDCLevel.add(lblDCLevelUnit);
    pnlControls.add(pnlAddDCLevel);
    // Anti-aliasing filter choice
    pnlFilter.setLayout(flowLayout6);
    pnlFilter.add(cbAntiAlias, null);
    pnlControls.add(pnlFilter);
    // Added random noise setting
    pnlAddNoise.setLayout(flowLayout4);
    pnlAddNoise.add(cbAddNoise);
    pnlAddNoise.add(tfNoise);
    pnlAddNoise.add(lblNoiseUnit);
    pnlControls.add(pnlAddNoise);
    // Time / frequency domain plot control
    pnlControls.add(pnlDomain, null);
    pnlDomain.add(cbSignal, null);
    pnlDomain.add(cbSpectrum, null);
    pnlDomain.add(btnPlot, null);
    isValidSignal = false;
    isValidSpectrum = false;
  }

  //Get Applet information
  public String getAppletInfo() {
    return "(C) 1997 Dr Iain A Robin";
  }

  //Get parameter info
  public String[][] getParameterInfo() {
    return new String[][] {{"Parameters:", "", ""},
            {"plcolor", "string", "Plot Colour"},
            {"bgcolor", "string", "Background Colour"},
            {"axcolor", "string", "Axis Colour"}};
  }

  void getSignal() {
    float[] op;
    int taps = 0;
    int nPoints = 1;
    sg.setWaveform(chWaveform.getSelectedItem());
    sg.setAmplitude(Float.valueOf(tfAmpl.getText()).floatValue());
    sg.setFrequency(Float.valueOf(tfFreq.getText()).floatValue());
    boolean addDC = cbAddDCLevel.getState();
    sg.setDCLevelState(addDC);
    if (addDC) sg.setDCLevel(Float.valueOf(tfDCLevel.getText()).floatValue());
    boolean addNoise = cbAddNoise.getState();
    sg.setNoiseState(addNoise);
    if (addNoise) sg.setNoise(Float.valueOf(tfNoise.getText()).floatValue());
    nSamples = Integer.parseInt(chSamples.getSelectedItem());
    boolean antiAlias = cbAntiAlias.getState();
    if (!antiAlias) {
      signal = new float[nSamples];
      sg.setSamples(nSamples);
      sg.setSamplingRate(8000.0f);
    }
    else {
      taps = aaf.getFilterTaps();
      nPoints = 6*nSamples + taps;
      signal = new float[nPoints];
      op = new float[nPoints];
      sg.setSamples(nPoints);
      sg.setSamplingRate(48000.0f);
    }
    signal = sg.generate();
    if (antiAlias) {
      // apply anti-alias filter to oversampled signal:
      op = aaf.filter(signal);
      // downsample by factor of 6 to restore original sampling rate
      // and throw away first 'taps' number of samples in filter output:
      signal = new float[nSamples];
      sg.setSamplingRate(8000.0f);
      for (int i = 0; i < nSamples; i++) signal[i] = op[6*i + taps];
    }
    wf.setWindowType(chWindow.getSelectedItem());
    float[] win = new float[nSamples];
    win = wf.generate(nSamples);
    maxValue = 1.0f;
    for (int i = 0; i < nSamples; i++) {
      signal[i] *= win[i];
      maxValue = Math.max(maxValue, Math.abs(signal[i]));
    }
    signalPlot.setYmax(maxValue);
    signalPlot.setPlotValues(signal);
    isValidSignal = true;
    isValidSpectrum = false;
  }

  void plotSignal() {
    if (!isValidSignal) getSignal();
    cardLayout1.show(pnlDisplay, "signal");
  }

  void getSpectrum() {
    spectrum = new float [nSamples / 2];
    spectrum = fft.fftMag(signal);
    maxValue = 1.0f;
    for (int i = 0; i < nSamples / 2; i++)
      maxValue = Math.max(maxValue, Math.abs(spectrum[i]));
    maxValue *= 1.2f;
    spectrumPlot.setYmax(maxValue);
    spectrumPlot.setPlotValues(spectrum);
    isValidSpectrum = true;
  }

  void plotSpectrum() {
    if (!isValidSignal) getSignal();
    if (!isValidSpectrum) getSpectrum();
    cardLayout1.show(pnlDisplay, "spectrum");
  }

  String floatToString(float f, int dp) {
    // convert float to string with specified number of decimal places
    String s = String.valueOf(f);
    int l = s.length();
    int p = s.indexOf('.') + dp + 1;
    if (p > l) p = l;
    return s.substring(0, p);
  }

  void btnPlot_actionPerformed(ActionEvent e) {
    if (cbSignal.getState()) plotSignal();
    else plotSpectrum();
  }

  void signalPlot_mouseMoved(MouseEvent e) {
    float t = 1000.0f*nSamples*(e.getX() - signalPlot.getHorzInset())
                / signalPlot.getXAxisLength() / sg.getSamplingRate();
    lblX.setText(floatToString(t, 2) + " ms");
    float V = maxValue*(signalPlot.getSize().height - 2*e.getY())
                / signalPlot.getPlotRect().height;
    lblY.setText(floatToString(V, 2) + " V");
  }

  void signalPlot_mouseExited(MouseEvent e) {
    lblX.setText(" ");
    lblY.setText(" ");
  }

  void spectrumPlot_mouseMoved(MouseEvent e) {
    float f = 0.5f*sg.getSamplingRate()*(e.getX() - spectrumPlot.getHorzInset())
               / spectrumPlot.getXAxisLength();
    lblX.setText(floatToString(f, -1) + " Hz");
    float V = maxValue*(spectrumPlot.getXAxisPos() - e.getY())
               / spectrumPlot.getYAxisLength();
    lblY.setText(floatToString(V, 2) + " V");
  }

  void spectrumPlot_mouseExited(MouseEvent e) {
    lblX.setText(" ");
    lblY.setText(" ");
  }

  void chWaveform_itemStateChanged(ItemEvent e) {
    isValidSignal = false;
  }

  void tfAmpl_textValueChanged(TextEvent e) {
    isValidSignal = false;
  }

  void tfFreq_textValueChanged(TextEvent e) {
    isValidSignal = false;
  }

  void chSamples_itemStateChanged(ItemEvent e) {
    isValidSignal = false;
  }

  void cbAddDCLevel_itemStateChanged(ItemEvent e) {
    isValidSignal = false;
  }

  void cbAddNoise_itemStateChanged(ItemEvent e) {
    isValidSignal = false;
  }

  void chWindow_itemStateChanged(ItemEvent e) {
    isValidSignal = false;
    if (cbSignal.getState()) plotSignal();
    else plotSpectrum();
  }

  void cbSignal_itemStateChanged(ItemEvent e) {
    plotSignal();
  }

  void cbSpectrum_itemStateChanged(ItemEvent e) {
    plotSpectrum();
  }

  void cbAntiAlias_itemStateChanged(ItemEvent e) {
    isValidSignal = false;
    if (cbSignal.getState()) plotSignal();
    else plotSpectrum();
  }

}


class Analyser_chWaveform_itemAdapter implements java.awt.event.ItemListener{
  Analyser adaptee;

  Analyser_chWaveform_itemAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void itemStateChanged(ItemEvent e) {
    adaptee.chWaveform_itemStateChanged(e);
  }
}

class Analyser_tfFreq_textAdapter implements java.awt.event.TextListener{
  Analyser adaptee;

  Analyser_tfFreq_textAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void textValueChanged(TextEvent e) {
    adaptee.tfFreq_textValueChanged(e);
  }
}

class Analyser_chSamples_itemAdapter implements java.awt.event.ItemListener{
  Analyser adaptee;

  Analyser_chSamples_itemAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void itemStateChanged(ItemEvent e) {
    adaptee.chSamples_itemStateChanged(e);
  }
}

class Analyser_cbAddDCLevel_itemAdapter implements java.awt.event.ItemListener{
  Analyser adaptee;

  Analyser_cbAddDCLevel_itemAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void itemStateChanged(ItemEvent e) {
    adaptee.cbAddDCLevel_itemStateChanged(e);
  }
}

class Analyser_cbAddNoise_itemAdapter implements java.awt.event.ItemListener{
  Analyser adaptee;

  Analyser_cbAddNoise_itemAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void itemStateChanged(ItemEvent e) {
    adaptee.cbAddNoise_itemStateChanged(e);
  }
}

class Analyser_chWindow_itemAdapter implements java.awt.event.ItemListener{
  Analyser adaptee;

  Analyser_chWindow_itemAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void itemStateChanged(ItemEvent e) {
    adaptee.chWindow_itemStateChanged(e);
  }
}


class Analyser_signalPlot_mouseAdapter extends java.awt.event.MouseAdapter {
  Analyser adaptee;

  Analyser_signalPlot_mouseAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void mouseExited(MouseEvent e) {
    adaptee.signalPlot_mouseExited(e);
  }

}

class Analyser_pnlDisplay_mouseAdapter extends java.awt.event.MouseAdapter {
  Analyser adaptee;

  Analyser_pnlDisplay_mouseAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

}

class Analyser_signalPlot_mouseMotionAdapter extends java.awt.event.MouseMotionAdapter {
  Analyser adaptee;

  Analyser_signalPlot_mouseMotionAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void mouseMoved(MouseEvent e) {
    adaptee.signalPlot_mouseMoved(e);
  }
}

class Analyser_spectrumPlot_mouseMotionAdapter extends java.awt.event.MouseMotionAdapter {
  Analyser adaptee;

  Analyser_spectrumPlot_mouseMotionAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void mouseMoved(MouseEvent e) {
    adaptee.spectrumPlot_mouseMoved(e);
  }
}

class Analyser_spectrumPlot_mouseAdapter extends java.awt.event.MouseAdapter {
  Analyser adaptee;

  Analyser_spectrumPlot_mouseAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void mouseExited(MouseEvent e) {
    adaptee.spectrumPlot_mouseExited(e);
  }
}

class Analyser_btnPlot_actionAdapter implements java.awt.event.ActionListener{
  Analyser adaptee;

  Analyser_btnPlot_actionAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void actionPerformed(ActionEvent e) {
    adaptee.btnPlot_actionPerformed(e);
  }
}

class Analyser_tfAmpl_textAdapter implements java.awt.event.TextListener{
  Analyser adaptee;

  Analyser_tfAmpl_textAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void textValueChanged(TextEvent e) {
    adaptee.tfAmpl_textValueChanged(e);
  }
}

class Analyser_cbSignal_itemAdapter implements java.awt.event.ItemListener{
  Analyser adaptee;

  Analyser_cbSignal_itemAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void itemStateChanged(ItemEvent e) {
    adaptee.cbSignal_itemStateChanged(e);
  }
}

class Analyser_cbSpectrum_itemAdapter implements java.awt.event.ItemListener{
  Analyser adaptee;

  Analyser_cbSpectrum_itemAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void itemStateChanged(ItemEvent e) {
    adaptee.cbSpectrum_itemStateChanged(e);
  }
}

class Analyser_cbAntiAlias_itemAdapter implements java.awt.event.ItemListener{
  Analyser adaptee;

  Analyser_cbAntiAlias_itemAdapter(Analyser adaptee) {
    this.adaptee = adaptee;
  }

  public void itemStateChanged(ItemEvent e) {
    adaptee.cbAntiAlias_itemStateChanged(e);
  }
}


