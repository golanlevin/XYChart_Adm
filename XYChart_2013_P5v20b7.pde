// For processing 2.0b7
// Version of February 2013, for entering class of Fall 2013

void setupChart() {
  chartX =  50;
  chartY =  700; 
  chartW =  650;
  chartH = -650;
}

//--------------------------------------------------
void handleChartMousePressed() {

  if (
  (mouseX > chartX) && (mouseX < (chartX+chartW+chartMargin)) && 
    (mouseY < chartY) && (mouseY > (chartY+chartH-chartMargin))) {
    cursorStudentList.clear();

    // otherwise choose a new student.
    // compute cursorStudentList
    int nStudents = studentVector.size();
    for (int i=0; i<nStudents; i++) {
      Student Si = ((Student) studentVector.get(i));
      if (Si.isChartPointInside(mouseX, mouseY)) {
        cursorStudentList.add(i);
      }
    }

    int nCursorStudents = cursorStudentList.size();
    if (nCursorStudents > 0) {
      if (nCursorStudents == 1) {
        currentStudentID = ((Integer)cursorStudentList.get(0)).intValue();
      } 
      else {
        for (int i=0; i<nCursorStudents; i++) {
          int index = ((Integer)cursorStudentList.get(i)).intValue();
          Student Si = ((Student) studentVector.get(index));
          println(Si.FIRSTNAME + " " + Si.LASTNAME);
        }

        println("---------");
      }
    }
  }
}





//--------------------------------------------
void drawChart() {
  drawChartRegionAndLabels();
  drawStudentsOnChart();
  drawChartCursorMagnification();
  drawCurrentStudentOnChart();
  drawRemarksForCurrentStudent();
}


//--------------------------------------------
void drawChartRegionAndLabels() {
  textFont(arialNarrow14); 
  fill (240);
  noStroke();
  rect(chartX, chartY, chartW+chartMargin, chartH-chartMargin); 


  stroke(0);
  line(chartX, chartY, chartX+chartW+chartMargin, chartY); 
  line(chartX, chartY, chartX, chartY+chartH-chartMargin); 


  for (float r=0; r<= MAX_RATING; r++) {
    if (r > 0) {
      float rx = ratingToChartPixelX (r);
      float ry = ratingToChartPixelY (r); 

      stroke(0);
      line (rx, chartY+chartMargin, rx, chartY) ;
      line (chartX-chartMargin, ry, chartX, ry) ;

      stroke(0, 0, 0, 18); 
      line (rx, chartY, rx, chartY+chartH) ;
      line (chartX, ry, chartX+chartW, ry) ;

      fill (0); 

      String label = ""+(int)r;
      text (label, rx-textWidth(label)/2.0, chartY+chartMargin+15);
      text (label, chartX-chartMargin-textWidth(label)-3, ry+5);
    }
  }

  fill(0); 
  text("Portfolio", chartX+4, chartY+15); 
  pushMatrix();
  translate(chartX, chartY); 
  rotate(PI + HALF_PI); 
  text("Interview", 4, -4); 
  popMatrix();
}

//--------------------------------------------
void drawChartCursorMagnification() {

  // compute destination coordinate square. 
  int dstX = (int)(chartX        + chartMargin/2);
  int dstY = (int)(chartY+chartH - chartMargin/2);
  int dstW = 120;
  int dstH = 120;

  // compute source coordinate square
  int srcW = 40; 
  int srcH = 40; 
  int srcX = (int) min(mouseX-srcW/2, chartX+chartW+chartMargin-srcW);
  int srcY = (int) min(mouseY-srcH/2, chartY-srcH); 
  srcX = (int) max(srcX, chartX); 
  srcY = (int) max(srcY, chartY+chartH-chartMargin);

  copy(srcX, srcY, srcW, srcH, dstX, dstY, dstW, dstH);
  stroke(0);
  fill(150, 100, 20, 40);
  rect(dstX, dstY, dstW, dstH);

  line(dstX+dstW/2, dstY, dstX+dstW/2, dstY+dstH); 
  line(dstX, dstY+dstH/2, dstX+dstW, dstY+dstH/2); 

  noFill();
  stroke(0, 0, 0, 48);
  rect(srcX, srcY, srcW, srcH);

  if (srcX+srcW < dstX+dstW) {
    line(dstX+dstW, dstY+dstH, srcX+srcW, srcY+srcH); 
    line(dstX, dstY+dstH, srcX, srcY+srcH);
  } 
  else if (srcY+srcH < dstY+dstH) {
    line(dstX+dstW, dstY, srcX+srcW, srcY); 
    line(dstX+dstW, dstY+dstH, srcX+srcW, srcY+srcH);
  }
  else {
    line(dstX+dstW, dstY, srcX+srcW, srcY); 
    line(dstX, dstY+dstH, srcX, srcY+srcH);
  }
}


//--------------------------------------------
void drawStudentsOnChart() {
  int nStudents = studentVector.size();
  for (int i=0; i<nStudents; i++) {
    Student Si = ((Student) studentVector.get(i));
    Si.drawOnChart();
  }
}


void outputAllStudentEvaluations() {
  PrintWriter output;
  output = createWriter("data/school-of-art-ratings-2012-02-15.txt");
  String aLine = "LASTNAME" + "\t" + "FIRSTNAME" + "\t" + "AVGPORTFOLIO" + "\t" + "AVGINTERVIEW";
  output.println(aLine); 

  int nStudents = studentVector.size();
  for (int i=0; i<nStudents; i++) {
    Student Si = ((Student) studentVector.get(i));
    float averagePortfolio = Si.averagePortfolio;
    float averageInterview = Si.averageInterview;
    aLine = Si.LASTNAME + "\t" + Si.FIRSTNAME + "\t" + nf(averagePortfolio, 1, 2) + "\t" + nf(averageInterview, 1, 2);
    output.println(aLine);
  }

  output.flush(); // Write the remaining data
  output.close(); // Finish the file
}


void printNPortfolioEvaluationReport() {
  int nWith1 = 0; 
  int nWith2 = 0; 

  int nWith[] = new int[13];
  int nStudents = studentVector.size();
  for (int i=0; i<nStudents; i++) {
    Student Si = ((Student) studentVector.get(i));
    int nEvaluations = Si.ratingArray.size();
    String aLine = Si.LASTNAME + ", " + Si.FIRSTNAME + "\t(" + nEvaluations + ")";
    //println(aLine);

    nEvaluations = min(nEvaluations, 12);

    /*if (nEvaluations >= 7){
     println(aLine);
     }*/

    if (nEvaluations <= 3) {

      int nSlideroom = 0; 
      for (int j=0; j<nEvaluations; j++) {
        Rating rj = (Rating) Si.ratingArray.get(j);
        if (rj.bOnCampus == false) {
          nSlideroom++;
        }
      }

      if (nSlideroom > 0) {
        print (aLine + "\t"); 
        for (int j=0; j<nEvaluations; j++) {
          Rating rj = (Rating) Si.ratingArray.get(j);
          print (rj.raterName + ", ");
        }
        println();
      }
    }


    nWith[nEvaluations] ++;
  }

  println("-----------"); 
  for (int i=0; i<13; i++) {
    println("# Students with " + i + " evaluations = " + nWith[i]);
  }
  println("total  = " + nStudents);
}


//--------------------------------------------
void printRaterActivity() {
}

//--------------------------------------------
void drawCurrentStudentOnChart() {
  Student Si = ((Student) studentVector.get(currentStudentID));
  Si.drawChartRatings();

  fill(100); 
  textFont(boldFont); 
  text(Si.getString(), chartX+5, chartY-5); 

  fill(0); 
  textFont(arialNarrow14); 
  text(searchName, chartX+5, chartY+chartH-chartMargin-5);
}



//--------------------------------------------------
void drawRemarksForCurrentStudent() {

  Student currStudent = (Student)studentVector.get(currentStudentID);
  ArrayList currStudentRatingArray = currStudent.ratingArray;
  int nRatings = currStudentRatingArray.size();

  fill(0, 0, 0); 
  textFont(arialNarrow14); 

  float textYPos = 320;
  float remarksX = chartX+chartW+40; 
  float remarksW = width - remarksX - 30; 

  line (remarksX, textYPos, remarksX+remarksW, textYPos);  
  textYPos += 20; 

  for (int i=0; i<nRatings; i++) {
    Rating Ri = (Rating)currStudentRatingArray.get(i);

    String ratingSummary = Ri.getRaterNameAndComment();
    
    char letterID = (char)('A' + i);
    String remark = letterID + ".  " + ratingSummary;
    float remarkWidth = textWidth(remark); 

    if (remarkWidth > remarksW) {
      int nLines = (int)ceil(remarkWidth / remarksW); 
      int nChars = remark.length();
      int totalCharCount = 0; 

      for (int j=0; j<nLines; j++) {
        String accum = "";
        float textXPos = (j==0) ? remarksX : remarksX+chartMargin;
        float maxLineWidth = ((j==0) ? remarksW+chartMargin: remarksW) - chartMargin; 
        while ( (textWidth (accum) < maxLineWidth) && (totalCharCount < nChars)) {
          accum += remark.charAt(totalCharCount);
          totalCharCount++;
        }
        if ((j != (nLines-1)) && (totalCharCount < nChars)) {
          if (remark.charAt(totalCharCount) != ' ') {
            accum += "-";
          }
        }
        text (accum, textXPos, textYPos);
        textYPos += textAscent() + textDescent();
      }
    } 
    else {
      text (remark, remarksX, textYPos);
      textYPos += textAscent() + textDescent();
    }
  }
}


//======================================================
float ratingToChartPixelX (float rating) {
  //float  out = map(rating, 0,MAX_RATING,  chartX,chartX+chartW);

  float out01 = map(rating, 0.5, MAX_RATING, 0, 1);
  float outWarped = 1.0-pow(1.0-out01, chartNonlinearity);
  float out = map(outWarped, 0, 1, chartX, chartX+chartW);

  return out;
}

//--------------------------------------------
float ratingToChartPixelY (float rating) {
  //float out = map(rating, 0,MAX_RATING,  chartY,chartY+chartH);

  float out01 = map(rating, 0.5, MAX_RATING, 0, 1);
  float outWarped = 1.0-pow(1.0-out01, chartNonlinearity);
  float out = map(outWarped, 0, 1, chartY, chartY+chartH);

  return out;
}

