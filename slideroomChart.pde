String rawFile[];
ArrayList studentVector;
ArrayList cursorStudentList; // list of student(s) under the cursor. 
HashMap raters;

final int MAX_RATING = 9; 

float chartX, chartY, chartW, chartH;
float chartNonlinearity = 1.25;
float chartMargin = 20; 

int currentStudentID;
String searchName;

import java.util.Iterator;

String slideroomRatingReportFilename = "Slideroom_Ratings_20130203.tsv"; 
String onCampusRatingReportFilename = "on-campus/OnCampus-2012-final-tsv.txt";
String testPrefix = "School of";
boolean bHaveOnCampusRatings = false;

PFont arialNarrow14; 
PFont  sixPixelFont;
PFont boldFont; 

boolean bObfuscateNamesForScreenshot = true;

//======================================================
void setup() {

  size(1280, 800); 
  loadFonts();

  setupChart();
  searchName = "";

  currentStudentID = 0;

  studentVector = new ArrayList<Student>();
  cursorStudentList = new ArrayList();
  raters = new HashMap();

  loadSlideroomRatingReport();
  
  if (bHaveOnCampusRatings){
    loadOnCampusRatingReport();
  }
  computeStudentStatistics();
}





//======================================================
void draw() {

  background(255);
  drawChart();
  drawRaters();
}

void mousePressed() {
  handleChartMousePressed();
}

void mouseDragged() {
  handleChartMousePressed();
}


int whichKim = 0;
//======================================================
void keyPressed() {

  if (key == CODED) { 
    if (keyCode == LEFT) { 
      currentStudentID = max(0, currentStudentID-1);
    }
    else if (keyCode == RIGHT) {
      currentStudentID = min(studentVector.size()-1, currentStudentID+1);
    }
  }

  else {


    if (searchName.length() == 0) {
      whichKim = 0;
    }

    if (key == 10) {
      whichKim++;
    } 

    if (key == 'N') {
      printNPortfolioEvaluationReport();
    } 
    else if (key == 'R') {
      printRatersSummary();
    } 
    else if (key == 'P') {
      //findStudentsReviewedByQuestionableRaters();
      outputAllStudentEvaluations();
    } 
    else if (key == 'A') {
      
      computeAverages();
      computeShapedRatings();
      computeStudentStatistics();
      
      
    }


    if (key == 8) {
      if (searchName.length() > 0) {
        searchName = searchName.substring(0, searchName.length()-1);
      }
    } 
    else {

      if (key != 10) {
        searchName += (char)key;
      }
      searchName = searchName.toLowerCase();
      boolean bFound = false;

      ArrayList kimVector = new ArrayList();
      int nStudents = studentVector.size();
      for (int i=0; i<nStudents; i++) {
        Student Si = ((Student) studentVector.get(i));
        String ln = Si.LASTNAME.toLowerCase();
        String fn = Si.FIRSTNAME.toLowerCase();

        if ((ln.startsWith(searchName)) ||
          (fn.startsWith(searchName))) {
          //bFound = true;
          //kimVector.add((int) i);
          currentStudentID = i;
        }
      }



      // println(kimVector); 
      // if (bFound) {
      // currentStudentID = ((Integer) kimVector.get(whichKim)).intValue();
    }
  }
}


//======================================================
void findStudentsWithRater(String queryR) {
  int nStudents = studentVector.size();
  for (int i=0; i<nStudents; i++) {
    Student S = ((Student) studentVector.get(i));

    ArrayList Rs = S.ratingArray;
    int nRatings = Rs.size();
    for (int j=0; j<nRatings; j++) {
      Rating R = (Rating) Rs.get(j);
      String Rname = R.raterName; 
      if (Rname.equals(queryR)) {
        println( S.LASTNAME + ", " + S.FIRSTNAME );
      }
    }
  }
}

//======================================================
void findStudentsReviewedByQuestionableRaters () {

  String questionableRaterNames[] = {
    "Questionable Ratername",
  };
  int nQuestionableRaterNames = questionableRaterNames.length;

  int nStudents = studentVector.size();
  for (int i=0; i<nStudents; i++) {
    Student S = ((Student) studentVector.get(i));
    ArrayList Rs = S.ratingArray;
    int nRatings = Rs.size();

    int nQuestionableRatersFound = 0;
    for (int j=0; j<nRatings; j++) {
      Rating Rj = (Rating) Rs.get(j);
      String Rnamej = Rj.raterName; 

      for (int k=0; k<nQuestionableRaterNames; k++) {
        if (Rnamej.equals(questionableRaterNames[k])) {
          nQuestionableRatersFound++;
        }
      }
    }

    if (nQuestionableRatersFound == nQuestionableRaterNames) {
      println(S.LASTNAME + ", " + S.FIRSTNAME);
    }
  }
}





//======================================================
void computeStudentStatistics() {
  int nStudents = studentVector.size();
  for (int i=0; i<nStudents; i++) {
    ((Student) studentVector.get(i)).computeStatistics();
  }
}


//======================================================
void printStudentVector() {
  int nStudents = studentVector.size();
  if (nStudents > 0) {

    String heading = ((Student) studentVector.get(0)).getHeadingString();
    println (heading);
    for (int i=0; i<nStudents; i++) {
      ((Student) studentVector.get(i)).printSummary();
    }
  }
}


String rot13 (String input) {
  String output = ""; 
  for (int i = 0; i < input.length(); i++) {
    char c = input.charAt(i);
    if       (c >= 'a' && c <= 'm') c += 13;
    else if  (c >= 'n' && c <= 'z') c -= 13;
    else if  (c >= 'A' && c <= 'M') c += 13;
    else if  (c >= 'A' && c <= 'Z') c -= 13;
    output += c;
  }
  return output;
}


