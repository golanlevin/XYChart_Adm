



class Rating {
  String   comment; 
  String   raterName;
  Student  forWhom;
  float    portfolioRating;
  float    interviewRating;
  FPoint   chartLocation;
  boolean  bOnCampus;

  Rating (float p, float i, String c, String rn, boolean bOn, Student stu) {
    chartLocation = new FPoint();
    portfolioRating = p;
    interviewRating = i;
    comment = c;
    raterName = rn;
    bOnCampus = bOn;
    forWhom = stu;
  }

  Rating getCopy() {
    Rating copyRating = new Rating (portfolioRating, interviewRating, comment, raterName, bOnCampus, forWhom); 
    return copyRating;
  }

  String getRaterNameAndComment() {
    
    String rn = raterName; 
    if (bObfuscateNamesForScreenshot){
      rn = rot13(raterName);
    }
    
    if (!comment.equals("")) {
      return (rn + ": " + comment);
    } 
    else {
      return (rn + ": ---");
    }
  }

  boolean isPointInside (float px, float py) {
    float dx = px - chartLocation.x;
    float dy = py - chartLocation.y;
    float halfSize = (ratingChartSize/2);
    return ((abs(dx) <= halfSize) && (abs(dy) <= halfSize));
  }
}

//==============================================================
void printRatersSummary() {
  Iterator iterator = raters.keySet().iterator();

  while (iterator.hasNext ()) {        
    String raterName = (String) iterator.next();
    Rater R = (Rater) raters.get(raterName); 
    R.printSelf();
  }
}

//---------------------------------
void drawRaters() {
  Iterator iterator = raters.keySet().iterator();
  int rc = 0; 
  float dim = 60; 
  int row = 7;

  while (iterator.hasNext ()) {     
    String raterName = (String) iterator.next();
    Rater R = (Rater) raters.get(raterName);
    if (R.nRatingsP > 0) {
      float rx = chartX+chartW+ 40 + (rc%row)*(dim+16);
      float ry = (dim+30) +(rc/row)*(dim+32);
      R.drawSelf(rx, ry, dim);
      rc++;
    }
  }
}

//---------------------------------
float overallRaterAverageP = 0; 
float overallRaterAverageI = 0; 
void computeAverages() {

  Iterator iterator = raters.keySet().iterator();
  int rc = 0; 

  float avgP = 0; 
  float avgI = 0; 
  while (iterator.hasNext ()) {     
    String raterName = (String) iterator.next();
    Rater aRater = (Rater) raters.get(raterName);
    aRater.computeAverages();
    if (aRater.averageP > 1) { 
      avgP += aRater.averageP; 
      avgI += aRater.averageI; 
      rc++;
    }
  }
  avgP /= (float)rc; 
  avgI /= (float)rc; 
  println ("Average Rater AverageP = " + avgP); 
  println ("Average Rater AverageI = " + avgI);
  println ("----------------------"); 
  overallRaterAverageP = avgP; 
  overallRaterAverageI = avgI; 
}


//---------------------------------
void computeShapedRatings() {

  Iterator iterator = raters.keySet().iterator();
  int rc = 0; 

  while (iterator.hasNext ()) {     
    String raterName = (String) iterator.next();
    Rater aRater = (Rater) raters.get(raterName);
    aRater.computeShapedRatings();
  }
}




