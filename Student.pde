
// some graphical variables pertaining to Student
float studentChartRadius = 5;
float ratingChartSize  = 12;
color ratingChartColor = color(64, 220, 64);



//=====================================================================
class Student {

  //---------------------
  // Properties from Admitulator

  String FIRSTNAME;
  String LASTNAME;

  //---------------------
  // Properties for Chart
  int SlideroomSubmissionId; 
  ArrayList ratingArray;
  FPoint    chartLocation;

  float averagePortfolio;
  float stdevPortfolio; 
  float rangePortfolio;
  float averageInterview;
  float stdevInterview; 
  float rangeInterview;
  float meanDifference; 



  Student() {
    ratingArray   = new ArrayList();
    chartLocation = new FPoint();
  }

  void addRating (Rating aRating) {
    ratingArray.add(aRating);
  }

  void printSummary() {
    println(getString());
  }

  //----------------------------------------------------
  boolean isChartPointInside (float px, float py) {
    float dx = px - chartLocation.x;
    float dy = py - chartLocation.y;
    float dh = sqrt (dx*dx + dy*dy); 
    return (dh <= studentChartRadius);
  }

  //----------------------------------------------------
  void drawOnChart() {
    chartLocation.x = ratingToChartPixelX (averagePortfolio); 
    chartLocation.y = ratingToChartPixelY (averageInterview);

    // bogus offset to reduce collisions
    boolean bDoCrappyOffset = false;
    if (bDoCrappyOffset) {
      float ang = TWO_PI * ((SlideroomSubmissionId%9)/9.0);
      float dx = 1 * studentChartRadius * cos(ang); 
      float dy = 1 * studentChartRadius * sin(ang); 
      chartLocation.x += dx; 
      chartLocation.y += dy;
    }

    smooth();
    noStroke();
    fill (0, 0, 0, 50); 
    ellipse(chartLocation.x, chartLocation.y, studentChartRadius*2, studentChartRadius*2);
    noSmooth();
  }

  //----------------------------------------------------
  void drawChartRatings() {

    int nRatings = ratingArray.size();
    float cX = chartLocation.x;
    float cY = chartLocation.y;

    // draw white ellipses
    smooth();
    noStroke();
    fill(255, 255, 255, 100); 
    ellipse(cX, cY, 20, 20);

    // compute rating locations, used throughout.
    for (int i=0; i<nRatings; i++) {
      Rating R = (Rating) ratingArray.get(i);
      float    pr = R.portfolioRating;
      float    ir = R.interviewRating;
      R.chartLocation.x = (pr > 0) ? ratingToChartPixelX (pr) : cX;
      R.chartLocation.y = (ir > 0) ? ratingToChartPixelY (ir) : cY;
    }

    // adjust rating locations if two ratings coincide. 
    for (int i=0; i<nRatings; i++) {
      int collisions = 0;
      for (int j=0; j<i; j++) {
        Rating Ri = (Rating) ratingArray.get(i);
        Rating Rj = (Rating) ratingArray.get(j);
        float    rpi = Ri.portfolioRating;
        float    rii = Ri.interviewRating;
        float    rpj = Rj.portfolioRating;
        float    rij = Rj.interviewRating;
        if ((rpi == rpj) && (rii == rij)) {
          if (collisions == 0) {
            Ri.chartLocation.x -= ratingChartSize/2;
          }
          Rj.chartLocation.x = Ri.chartLocation.x + ratingChartSize;
          collisions++;
        }
      }
    }

    // draw white boxes behind Ratings
    noStroke();
    for (int i=0; i<nRatings; i++) {
      Rating R = (Rating) ratingArray.get(i);
      float rx = R.chartLocation.x;
      float ry = R.chartLocation.y;

      fill(255, 255, 255, 64);
      rect (rx-12, ry-12, 24, 24);
      fill(255, 255, 255, 160);
      rect (rx-8, ry-8, 16, 16);
    }

    // draw white lines
    float bez = 4.0;
    noFill();
    smooth();
    for (int i=0; i<nRatings; i++) {
      Rating R = (Rating) ratingArray.get(i);
      float rx = R.chartLocation.x;
      float ry = R.chartLocation.y;

      float dx = (rx - cX);
      float dy = (ry - cY);
      float bx0 = (abs(dx) > abs(dy)) ? dx/bez : 0;
      float by0 = (abs(dy) > abs(dx)) ? dy/bez : 0;

      stroke(255, 255, 255, 50);
      strokeWeight(13);
      bezier (cX, cY, cX+bx0, cY+by0, rx-bx0, ry-by0, rx, ry); 
      stroke(255, 255, 255, 100);
      strokeWeight(7);
      bezier (cX, cY, cX+bx0, cY+by0, rx-bx0, ry-by0, rx, ry); 
      stroke(255, 255, 255, 200);
      strokeWeight(5);
      bezier (cX, cY, cX+bx0, cY+by0, rx-bx0, ry-by0, rx, ry);
    }

    // draw black lines
    noFill();
    stroke(0);
    strokeWeight(1.5);
    for (int i=0; i<nRatings; i++) {
      Rating R = (Rating) ratingArray.get(i);
      float rx = R.chartLocation.x;
      float ry = R.chartLocation.y;

      float dx = (rx - cX);
      float dy = (ry - cY);
      float bx0 = (abs(dx) > abs(dy)) ? dx/bez : 0;
      float by0 = (abs(dy) > abs(dx)) ? dy/bez : 0;

      bezier (cX, cY, cX+bx0, cY+by0, rx-bx0, ry-by0, rx, ry);
    }

    // draw pink ellipse for student
    stroke(0);
    strokeWeight(1.5);
    fill(255, 160, 160);
    ellipse(cX, cY, 16, 16);

    // draw mean difference between ratings
    boolean bDrawMeanDifference = true;
    if (bDrawMeanDifference) {
      float er = meanDifference * 60;
      noStroke();
      fill(160, 160, 160, 50);
      ellipse(cX, cY, er, er);
    }

    // draw green boxes
    noSmooth();
    strokeWeight(1);
    textFont(sixPixelFont, 6); 

    for (int i=0; i<nRatings; i++) {
      Rating R = (Rating) ratingArray.get(i);
      float rx = R.chartLocation.x;
      float ry = R.chartLocation.y;
      float rs = ratingChartSize;

      noStroke(); 
      fill (ratingChartColor);
      rect (rx-6, ry-6, rs, rs);
      noFill();
      stroke(0, 0, 0);
      rect (rx-7, ry-7, rs+1, rs+1);

      fill(0, 0, 0); 
      text(char('A'+i), rx-1, ry+3);
    }

    strokeWeight(1);
  }



  String getHeadingString() {
    String output = "SubmId" + "\t" + "LastName" + "\t" + "FirstName";

    output += "\t" + "AvgPortf";
    output += "\t" + "RangePortf";
    output += "\t" + "StdevPortf"; 

    output += "\t" + "AvgInterv";
    output += "\t" + "RangeInterv";
    output += "\t" + "StdevInterv";
    return output;
  }



  String getString() {

    String output = LASTNAME + ", " + FIRSTNAME + ": (" + nf(averagePortfolio, 1, 2) + ", " + nf(averageInterview, 1, 2) + ")"; 

    // String output = "" + SlideroomSubmissionId + "\t" + LASTNAME + "\t" + FIRSTNAME;

    //output += "\t" + portfolioRatings;
    //output += "\t" + interviewRatings;

    /*
    output += "\t" + nf(averagePortfolio, 1,2);
     output += "\t" + rangePortfolio;
     output += "\t" + nf(stdevPortfolio, 1, 2); 
     output += "\t" + portfolioRatings;
     
     output += "\t" + nf(averageInterview, 1,2);
     output += "\t" + rangeInterview;
     output += "\t" + nf(stdevInterview, 1, 2); 
     output += "\t" + interviewRatings;
     */
    return output;
  }



  //-----------------------------------------------
  void computeStatistics() {

    // Portfolio
    averagePortfolio = 0; 
    stdevPortfolio = 0; 
    rangePortfolio = 0; 

    averageInterview = 0; 
    stdevInterview = 0; 
    rangeInterview = 0; 

    int nRatings = ratingArray.size();
    if (nRatings > 0) {

      float portfolioSum = 0; 
      float nPortfolioRatings = 0; 
      float minpVal = 10; 
      float maxpVal = 0;

      float interviewSum = 0; 
      int nInterviewRatings = 0; 
      float miniVal = 10; 
      float maxiVal = 0;   

      for (int i=0; i<nRatings; i++) {
        Rating R = (Rating) ratingArray.get(i); 

        float pval = R.portfolioRating;
        float ival = R.interviewRating; 


        if (pval > 0) {
          nPortfolioRatings++;
          if (pval < minpVal) {
            minpVal = pval;
          }
          if (pval > maxpVal) {
            maxpVal = pval;
          }
          portfolioSum += pval;
        }




        if (ival > 0) {
          nInterviewRatings++;
          if (ival < miniVal) {
            miniVal = ival;
          }
          if (ival > maxiVal) {
            maxiVal = ival;
          }
          interviewSum += ival;
        }
      }

      averagePortfolio = (float) portfolioSum / (float) nPortfolioRatings;
      rangePortfolio   = (maxpVal - minpVal);
      for (int i=0; i<nPortfolioRatings; i++) {
        Rating R = (Rating) ratingArray.get(i);
        if (R.portfolioRating > 0) {
          float term = (float)(R.portfolioRating) - averagePortfolio;
          stdevPortfolio += term*term;
        }
      }
      stdevPortfolio = sqrt (stdevPortfolio / (float)nPortfolioRatings) ;

      averageInterview = (float) interviewSum / (float) nInterviewRatings;  
      rangeInterview   = (maxiVal - miniVal);
      for (int i=0; i<nInterviewRatings; i++) {
        Rating R = (Rating) ratingArray.get(i);
        if (R.interviewRating > 0) {
          float term = (float)(R.interviewRating) - averageInterview;
          stdevInterview += term*term;
        }
      }
      stdevInterview = sqrt (stdevInterview / (float)nInterviewRatings) ;


      // meanDifference
      meanDifference = sqrt(stdevInterview*stdevInterview + stdevPortfolio*stdevPortfolio);
    }
  }
}

