//-------------------------------------------------------------
class Rater {
  String name;
  ArrayList ratingArray; // of type Rating.
  ArrayList ratingArrayShaped; 
  int ratingCountsP[];
  int ratingCountsI[];
  int nRatingsP;
  int nRatingsI;
  float averageP = 0;
  float averageI = 0;


  Rater (String s) {
    name = s;

    ratingArray  = new ArrayList();
    ratingArrayShaped = new ArrayList();

    nRatingsP = nRatingsI = 0;
    ratingCountsP = new int[10];
    ratingCountsI = new int[10];
    for (int i=0; i<9; i++) {
      ratingCountsP[i] = ratingCountsI[i] = 0;
    }
  }

  //=============================================================================
  void computeShapedRatings() {
    ratingArrayShaped.clear();

    int nRatings = ratingArray.size();
    for (int i=0; i<nRatings; i++) {
      Rating aRating = (Rating) ratingArray.get(i); 
      Rating ratingCopy = aRating.getCopy();
      ratingArrayShaped.add(ratingCopy);
    }

    ArrayList originalArrayP = new ArrayList();
    for (int i=0; i<nRatings; i++) {
      Rating aRating = (Rating) ratingArray.get(i); 
      float aRatingVal = aRating.portfolioRating;
      if (aRatingVal > 0) {
        float aRatingVal01 = map(aRatingVal, 1, 9, 0.0, 1.0);
        originalArrayP.add(aRatingVal01);
      }
    }
    float targetAverage = map (overallRaterAverageP, 1, 9, 0, 1);
    float shapingPower = getShapingPower ( targetAverage, originalArrayP);
    for (int i=0; i<nRatings; i++) {
      Rating aRating = (Rating) ratingArray.get(i); 
      float aRatingVal = aRating.portfolioRating;
      if (aRatingVal > 0) {
        aRatingVal = map (aRatingVal, 1, 9, 0, 1); 
        aRatingVal = pow (aRatingVal, shapingPower);
        aRatingVal = map (aRatingVal, 0, 1, 1, 9);  
        aRating.portfolioRating = aRatingVal;
      }
    }


    ArrayList originalArrayI = new ArrayList();
    for (int i=0; i<nRatings; i++) {
      Rating aRating = (Rating) ratingArray.get(i); 
      float aRatingVal = aRating.interviewRating;
      if (aRatingVal > 0) {
        float aRatingVal01 = map(aRatingVal, 1, 9, 0.0, 1.0);
        originalArrayI.add(aRatingVal01);
      }
    }
    targetAverage = map (overallRaterAverageI, 1, 9, 0, 1);
    shapingPower = getShapingPower ( targetAverage, originalArrayI);
    for (int i=0; i<nRatings; i++) {
      Rating aRating = (Rating) ratingArray.get(i); 
      float aRatingVal = aRating.interviewRating;
      if (aRatingVal > 0) {
        aRatingVal = map (aRatingVal, 1, 9, 0, 1); 
        aRatingVal = pow (aRatingVal, shapingPower);
        aRatingVal = map (aRatingVal, 0, 1, 1, 9);  
        aRating.interviewRating = aRatingVal;
      }
    }
  }




  //=============================================================================
  void addRating (Rating aRating) {
    ratingArray.add(aRating);
    float rp = aRating.portfolioRating; 
    float ri = aRating.interviewRating;
    if (rp > 0) {
      ratingCountsP[(int)rp]++;
      nRatingsP++;
    }
    if (ri > 0) {
      ratingCountsI[(int)ri]++;
      nRatingsI++;
    }
  }




  void printSelf() {

    String prName = name;
    if (bObfuscateNamesForScreenshot == true) {
      prName  = rot13(name);
    }
    
    while (prName.length () < 20) {
      prName += " ";
    }

    float avgP = getAverageRatingP();
    float avgI = getAverageRatingI();   
    println (prName + "\t" + ratingArray.size() + "\t" + nf(avgP, 1, 3) + "\t" + nf(avgI, 1, 3) );
  }

  void drawSelf (float x, float y, float dim) {
    pushMatrix();
    translate(x, y); 
    stroke (0, 0, 0); 
    line (0, 0, 0, -dim);
    line (0, 0, dim, 0);

    // find max in ratings to normalize
    float myMax = 0;
    for (int i=0; i<10; i++) {
      if (ratingCountsP[i] > myMax) {
        myMax = (float) ratingCountsP[i];
      }
    }

    stroke (96, 0, 0, 180);
    strokeWeight (2.0);

    smooth();
    noFill();
    beginShape();
    for (int i=1; i<10; i++) {
      float px = map(i, 0, 10, 0, dim);
      float py = 0-map(ratingCountsP[i], 0, myMax, 0, dim);
      vertex (px, py);
    }
    endShape();
    strokeWeight (1.0);
    stroke (0, 0, 0, 32);
    for (int i=1; i<10; i++) {
      float px = map(i, 0, 10, 0, dim);
      float py = 0-map(ratingCountsP[i], 0, myMax, 0, dim);
      line (px, py, px, 0);
    }
    noSmooth();


    fill (0, 0, 0); 
    textFont(arialNarrow14, 12); 
    int indexOfLastName = name.indexOf(' '); 
    String lastName = name;
    if (indexOfLastName > 0) {
      lastName = name.substring(indexOfLastName, name.length());
    }
    lastName = trim(lastName); 
    if (bObfuscateNamesForScreenshot == true) {
      lastName  = rot13(lastName);
    }
    
    float averageP = getAverageRatingP(); 
    int nRatings = ratingArray.size();
    text(lastName + ": " + nRatings + "/" + nf(averageP, 1, 1), 0, 16);


    popMatrix();
  }



  float getMedianRatingP() {
    return computeRatingMedian (ratingArray, 'P');
  }
  float getMedianRatingI() {
    return computeRatingMedian (ratingArray, 'I');
  }

  void computeAverages() {
    getAverageRatingP();
    getAverageRatingI();
  }

  float getAverageRatingP() {
    averageP = computeRatingAverage (ratingArray, 'P');
    return averageP;
  }

  float getAverageRatingI() {
    averageI = computeRatingAverage (ratingArray, 'I');
    return averageI;
  }
}

