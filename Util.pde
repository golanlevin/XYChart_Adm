

class FPoint {
  float x; 
  float y;
}


float sign (float num) {
  if (num < 0) {
    return -1;
  } 
  return 1;
}


String stripQuotesAndTrim (String inputStr) {
  String quoteStr = "" + '"';
  if (inputStr.startsWith(quoteStr) && (inputStr.endsWith(quoteStr))) {
    inputStr = inputStr.substring(1, inputStr.length()-1); 
    inputStr = inputStr.trim();
  }
  return inputStr;
}

String stripFinalNewline (String inputStr){
  String newlineStr = "" + '\n'; 
  if (inputStr.endsWith(newlineStr)){
    inputStr = inputStr.substring(1, inputStr.length()-1); 
    inputStr = inputStr.trim();
  }
  return inputStr;
}



//====================================================================
float computeRatingAverage (ArrayList ratings, char which) {
    float average = 0; 
    int nRatings = ratings.size();
    float ratingCount = 0; 
    
    if (nRatings > 0) {
      for (int i=0; i<nRatings; i++) {
        Rating aRating = (Rating)ratings.get(i);
        float aRatingVal = 0; 
        if (which == 'P'){
          aRatingVal = aRating.portfolioRating;
        } else if (which == 'I'){
          aRatingVal = aRating.interviewRating;
        }
        
        if (aRatingVal > 0){
          average += aRatingVal;
          ratingCount++;
        }
      }
      if (ratingCount == 0){
        return 0;
      }
      average /= ratingCount;
    }
    return average;
  }


//====================================================================
float computeRatingMedian (ArrayList ratings, char which) {
  int nRatings = ratings.size();
  if (nRatings == 0){
    return 0;
  } 
  
  int nValidValues = 0; 
  for (int i=0; i<nRatings; i++) {
    Rating aRating = (Rating) ratings.get(i); 
    float aVal = 0; 
    if (which == 'P'){
      aVal = aRating.portfolioRating;
    } else if (which == 'I'){
      aVal = aRating.interviewRating;
    }
    if (aVal > 0){
      nValidValues++;
    }
  }
  
  if (nValidValues == 0){
    return 0;
  }
  
  float valArray[] = new float[nValidValues];
  nValidValues = 0; 
  for (int i=0; i<nRatings; i++) {
    Rating aRating = (Rating) ratings.get(i); 
    float aVal = 0; 
    if (which == 'P'){
      aVal = aRating.portfolioRating;
    } else if (which == 'I'){
      aVal = aRating.interviewRating;
    }
  
    if (aVal > 0){
      valArray[nValidValues] = aVal;
      nValidValues ++;
    }
  }
  float sortedValArray[] = new float[nValidValues];
  sortedValArray = sort (valArray); 

  float median = 0;
  if (nValidValues > 1) {
    if (nValidValues%2 == 0) {
      median = (sortedValArray[nValidValues/2 -1] + sortedValArray[nValidValues/2])/2.0;
    } 
    else {
      median = sortedValArray[nValidValues/2];
    }
  } 
  else {
    median = sortedValArray[0];
  }

  return median;
}




//================================================================
float getShapingPower (float targetAverage, ArrayList originalArray) {
  int narr = originalArray.size();
  
  float arrCopy[] = new float[narr];
  for (int i=0; i<narr; i++) {
    arrCopy[i] = ((Float)originalArray.get(i)).floatValue();
  }

  float realAvg = 0; 
  for (int i=0; i<narr; i++) {
    realAvg += ((Float)originalArray.get(i)).floatValue();
  }
  realAvg /= (float) narr;
  // println (realAvg); 

  float somePower = 1.0; 
  int iterationCount = 0; 
  float precision = 0.0005;

  if (targetAverage > realAvg) {
    while ( ( (targetAverage - realAvg) > precision) && (somePower > 0) && (iterationCount < 2500)) {
      somePower -= precision;
      for (int i=0; i<narr; i++) {
        float origVal = ((Float)originalArray.get(i)).floatValue();
        arrCopy[i] = pow (origVal, somePower);
      }
      realAvg = 0; 
      for (int i=0; i<narr; i++) {
        realAvg += arrCopy[i];
      }
      realAvg /= (float) narr;
      iterationCount++;
      // println (iterationCount + "\tT: " + nf(targetAverage, 1, 3) + "\t" + "R: " + nf(realAvg, 1, 3) + "\t" + somePower);
    }
  } 
  else {

    while ( ( (realAvg - targetAverage) > precision) && (somePower < 4.0) && (iterationCount < 2500)) {
      somePower += precision;
      for (int i=0; i<narr; i++) {
        float origVal = ((Float)originalArray.get(i)).floatValue();
        arrCopy[i] = pow (origVal, somePower);
      }
      realAvg = 0; 
      for (int i=0; i<narr; i++) {
        realAvg += arrCopy[i];
      }
      realAvg /= (float) narr;
      iterationCount++;
      // println (iterationCount + "\tT: " + nf(targetAverage, 1, 3) + "\t" + "R: " + nf(realAvg, 1, 3) + "\t" + somePower);
    }
  }
  //println ("iterationCount = " + iterationCount); 
  return somePower;
}
