package dsp;

import java.awt.*;

public class GraphPlot extends Canvas {

  public static final int SIGNAL = 1;
  public static final int SPECTRUM = 2;

  Graphics graphics;
  Rectangle plotRect = new Rectangle();
  Color plotColor = Color.green;
  Color axisColor = Color.lightGray;
  Color gridColor = Color.lightGray;
  Color bgColor   = Color.black;
  int plotStyle = SIGNAL;
  boolean tracePlot = true;
  boolean logScale = false;
  int vertInset = 20;
  int horzInset = 20;
  int xAxisPos;
  int vertIntervals = 8;
  int horzIntervals = 10;
  int nPoints = 0;
  float xmax = 0.0f;
  float ymax = 0.0f;
  private float[] plotValues;

  public GraphPlot() {
  }

  public void setPlotColor(Color c) {
    if (c != null) plotColor = c;
  }

  public Color getPlotColor() {
    return plotColor;
  }

  public void setAxisColor(Color c) {
    if (c != null) axisColor = c;
  }

  public Color getAxisColor() {
    return axisColor;
  }

  public void setGridColor(Color c) {
    if (c != null) gridColor = c;
  }

  public Color getGridColor() {
    return gridColor;
  }

  public void setBgColor(Color c) {
    if (c != null) bgColor = c;
  }

  public Color getBgColor() {
    return bgColor;
  }

  public void setPlotStyle(int pst) {
    plotStyle = pst;
  }

  public int getPlotStyle() {
    return plotStyle;
  }

  public void setTracePlot(boolean b) {
    tracePlot = b;
  }

  public boolean isTracePlot() {
    return tracePlot;
  }

  public void setLogScale(boolean b) {
    logScale = b;
  }

  public boolean isLogScale() {
    return logScale;
  }

  public void setHorzInset(int h) {
    // horizontal inset for plot area from canvas boundary
    horzInset = h;
  }

  public void setVertInset(int v) {
    // vertical inset for plot area from canvas boundary
    vertInset = v;
  }

  public int getVertInset() {
    return vertInset;
  }

  public int getHorzInset() {
    return horzInset;
  }

  public int getXAxisLength() {
    return plotRect.getSize().width;
  }

  public int getXAxisPos() {
    return xAxisPos;
  }

  public int getYAxisLength() {
    return plotRect.getSize().height;
  }

  public Dimension getPlotSize() {
    return plotRect.getSize();
  }

  public Rectangle getPlotRect() {
    return plotRect;
  }

  public int getVertIntervals() {
    return vertIntervals;
  }

  public void setVertIntervals(int i) {
    vertIntervals = i;
  }

  public int getHorzIntervals() {
    return horzIntervals;
  }

  public void setHorzIntervals(int i) {
    horzIntervals = i;
  }

  public void setYmax(float m) {
    ymax = m;
  }

  public float getYmax() {
    return ymax;
  }

  public void setPlotValues(float[] values) {
    nPoints = values.length;
    plotValues = new float[nPoints];
    plotValues = values;
    repaint();
  }

  public void drawGrid() {
    int x, y;
    graphics.setColor(gridColor);
    // vertical grid lines
    for (int i = 0; i <= vertIntervals; i++) {
      x = plotRect.x + i*plotRect.width/vertIntervals;
      graphics.drawLine(x, plotRect.y, x, plotRect.y + plotRect.height);
    }
    // horizontal grid lines
    for (int i = 0; i <= horzIntervals; i++) {
      y = plotRect.y + i*plotRect.height/horzIntervals;
      graphics.drawLine(plotRect.x, y, plotRect.x + plotRect.width, y);
    }
  }

  public void drawAxes() {
    xAxisPos = plotRect.y + plotRect.height / 2;
    if (plotStyle == SPECTRUM) xAxisPos = plotRect.y + plotRect.height;
    if (logScale) xAxisPos = plotRect.y;
    graphics.setColor(axisColor);
     // vertical axis:
    graphics.drawLine(plotRect.x, plotRect.y,
                        plotRect.x, plotRect.y + plotRect.height);
    // horizontal axis:
    graphics.drawLine(plotRect.x, xAxisPos,
                        plotRect.x + plotRect.width, xAxisPos);
  }

  public void plotPoints() {
    if (nPoints != 0) {
      graphics.setColor(plotColor);
      // default plot type has x axis in middle of plot with + and - y axes:
      xAxisPos = plotRect.y + plotRect.height / 2;
      float xScale = plotRect.width/(float)nPoints;
      float yScale = 0.5f*plotRect.height/ymax;
      if (plotStyle == SPECTRUM) {
        xAxisPos = plotRect.y + plotRect.height; // x axis at bottom of plot
        yScale = plotRect.height/ymax; // vertical scale based on full plot height
      }
      if (logScale) xAxisPos = plotRect.y; // x axis at top of plot (0 dB)
      int[] xCoords = new int[nPoints];
      int[] yCoords = new int[nPoints];
      for (int i = 0; i < nPoints; i++) {
         xCoords[i] = plotRect.x + Math.round(i*xScale);
         yCoords[i] = xAxisPos - Math.round(plotValues[i]*yScale);
      }
      if (tracePlot)
        graphics.drawPolyline(xCoords, yCoords, nPoints);
      else { // bar plot
        for (int i = 0; i < nPoints; i++)
          graphics.drawLine(xCoords[i], xAxisPos, xCoords[i], yCoords[i]);
      }
    }
  }

  public void paint(Graphics g) {
    this.graphics = g;
    this.setBackground(bgColor);
    // define the location and size of the plot area:
    plotRect.setBounds(horzInset,
                       vertInset,
                       getSize().width - 2*horzInset,
                       getSize().height - 2*vertInset);
    drawAxes();
    if (logScale) drawGrid();
    plotPoints();
  }
}
