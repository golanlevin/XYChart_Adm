

//======================================================
void loadFonts() {
  arialNarrow14 = loadFont("fonts/ArialNarrow-14.vlw"); 
  sixPixelFont  = loadFont("fonts/6px2bus24.vlw"); 
  boldFont =    loadFont("fonts/Helvetica-Bold-24.vlw");
}


//======================================================
void loadOnCampusRatingReport () {
  // This will always be done AFTER slideroom students are loaded, OK? 

  // Format: LastName	FirstName	Interview	Faculty	Port1	Faculty	Port2	Faculty	Port3	Faculty	Major
  String onCampusRawLines[] = loadStrings (onCampusRatingReportFilename);
  int nOnCampusRawLines = onCampusRawLines.length;
  if (nOnCampusRawLines > 1) { // 1st line is header
    for (int i=1; i<nOnCampusRawLines; i++) {

      String aLine = onCampusRawLines[i]; 
      String aLineElements[] = split(aLine, '\t');
      if (aLineElements.length == 11) {
        String studentLastName  = aLineElements[0].trim();
        String studentFirstName = aLineElements[1].trim();
        if (bObfuscateNamesForScreenshot == true){
          studentLastName  = rot13(studentLastName); 
          studentFirstName = rot13(studentFirstName);
        }

        // Test to see if there is already a (previous/Slideroom) student with this name. 
        Student currentStudent = new Student();
        boolean bPreviousMatchFound = false;
        int nPreviousStudents = studentVector.size();
        for (int j=0; j<nPreviousStudents; j++) {
          Student Sj = (Student) studentVector.get(j);
          String Sjln = Sj.LASTNAME.toLowerCase();
          String Sjfn = Sj.FIRSTNAME.toLowerCase();
          String Siln = studentLastName.toLowerCase();
          String Sifn = studentFirstName.toLowerCase();
          if (Siln.equals(Sjln) && Sifn.equals(Sjfn)) {
            
            // Watch out for students with exactly the same name. 
            // In fact, this happened at least once, with Daniel Kim.
            // Include a comparison on the ID number. 
            println ("ALERT: previous rating found for: " + studentLastName + " " + studentFirstName); 
            bPreviousMatchFound = true;
            currentStudent = Sj;
          }
        }
        if (bPreviousMatchFound == false) {
          currentStudent.SlideroomSubmissionId = 0;
          currentStudent.FIRSTNAME = studentFirstName;
          currentStudent.LASTNAME  = studentLastName;
          studentVector.add (currentStudent);
        }

        // There is only one interview rating for the on-campus reviews,
        // and it might also be accompanied by a portfolio review by the same person. 
        // Since the interview rating comes first, store it temporarily to see 
        // if we later see a portfolio rating by the same faculty. 

        int interviewRating = -1;
        String interviewRaterName = ""; 
        boolean bARaterDidBothInterviewAndPortfolio = false;
        String ratingComment  = "";
        boolean bOnCampus     = true;

        for (int r=2; r<=8; r+=2) {

          String raterRatingStr = aLineElements[r  ];
          String raterName      = aLineElements[r+1].trim();
          int portfolioRating   = -1;

          int ratingVal = -1;
          try {
            ratingVal = Integer.parseInt ( raterRatingStr);
          } 
          catch (NumberFormatException e) {
            ;
          }
          if (ratingVal != -1) {
            // caution, there is the possibility that this isn an on-campus review for a Slideroom student!

            if (r == 2) {
              interviewRating = ratingVal;
              interviewRaterName = raterName;
            } 
            else {
              portfolioRating = ratingVal;
            }

            Rating theRating = null; 
            if (r > 2) {
              if (raterName.equals(interviewRaterName)) {
                bARaterDidBothInterviewAndPortfolio = true;
                // println ("Rater did both port and interview on Campus: " + interviewRaterName + "\t" + currentStudent.LASTNAME);
                Rating aRating = new Rating (portfolioRating, interviewRating, ratingComment, raterName, bOnCampus, currentStudent);
                currentStudent.addRating ( aRating );
                theRating = aRating;
              } 
              else {
                Rating aRating = new Rating (portfolioRating, -1, ratingComment, raterName, bOnCampus, currentStudent);
                currentStudent.addRating ( aRating );
                theRating = aRating; 
              }
            }

            // add Raters
            if (raters.containsKey(raterName)) {
              Rater aRater = (Rater) raters.get(raterName);
              //aRater.addRatings (portfolioRating, interviewRating);
              if (theRating != null){
                aRater.addRating (theRating); 
              }
            } 
            else {
              Rater aRater1 = new Rater(raterName);
              // aRater1.addRatings (portfolioRating, interviewRating);
              if (theRating != null){
                aRater1.addRating (theRating); 
              }
              raters.put (aRater1.name, aRater1);
            }
          }

          ;
        }

        // handle the case in which no subsequent portfolio rater was also responsible for the interview rating. 
        if (bARaterDidBothInterviewAndPortfolio == false) {
          // println ("Unique interview rater on Campus: " + interviewRaterName + " " + currentStudent.LASTNAME);
          int portfolioRating = -1;
          Rating aRating = new Rating (portfolioRating, interviewRating, ratingComment, interviewRaterName, bOnCampus, currentStudent);
          currentStudent.addRating ( aRating ); 

          // add Raters
          if (raters.containsKey(interviewRaterName)) {
            Rater aRater = (Rater) raters.get(interviewRaterName);
            aRater.addRating (aRating);
            // aRater.addRatings (portfolioRating, interviewRating);
          } 
          else {
            Rater aRater1 = new Rater(interviewRaterName);
            aRater1.addRating (aRating); 
            //aRater1.addRatings (portfolioRating, interviewRating);
            raters.put (aRater1.name, aRater1);
          }
        }
      } 
      else {
        
        // file input line lacks 11 elements. Missing a rating? 
        println("Faulty input in on-campus ratings: " + aLine);
      }
    }
  }
}



//======================================================
void loadSlideroomRatingReport () {

  // load the raw file from Slideroom
  rawFile = loadStrings(slideroomRatingReportFilename); 
  int nLinesRaw = rawFile.length;
  int nLines = nLinesRaw;


  // Deal with the fact that some of the Raters' comments contain return characters. 
  // Therefore a simple loadStrings() won't work. Concatenate lines broken up in this way.
  ArrayList linesWithReturnsFiltered = new ArrayList();
  for (int i=0; i<nLinesRaw; i++) {
    if ((i==0) || (rawFile[i].startsWith (testPrefix))) {
      linesWithReturnsFiltered.add ( rawFile[i] );
    } 
    else {
      int count = linesWithReturnsFiltered.size();
      String lineSoFar = (String) linesWithReturnsFiltered.get(count-1); 
      lineSoFar += rawFile[i];
      linesWithReturnsFiltered.set(count-1, lineSoFar);
    }
  }

  String linesClean[] = new String[linesWithReturnsFiltered.size()];
  linesWithReturnsFiltered.toArray(linesClean);

  // linesClean now contains the corrected lines, one per rating. 
  rawFile = null;
  rawFile = linesClean;
  nLines = linesClean.length;


  int previousSubmissionId = -1;
  Student currentStudent = null;

  if (nLines > 1) {
    int dataStartLine = 1;
    for (int i=dataStartLine; i<nLines; i++) {

      String aLine = rawFile[i];
      // println (nf(i,3) + "\t" + aLine); 

      String aLineElements[] = split(aLine, '\t');

      int submissionIdIndex = 1; // line item 1 is the SubmissionID
      int ithLineSubmissionId = (int) Long.parseLong(aLineElements[submissionIdIndex]);
      if (ithLineSubmissionId != previousSubmissionId) {
        previousSubmissionId = ithLineSubmissionId;

        int    firstNameIndex = 5; 
        int    lastNameIndex  = 6; 
        String firstName = aLineElements[firstNameIndex];
        String lastName  = aLineElements[lastNameIndex];
        
        if (bObfuscateNamesForScreenshot == true){
          lastName  = rot13(lastName); 
          firstName = rot13(firstName);
        }

        currentStudent = new Student();
        currentStudent.SlideroomSubmissionId = ithLineSubmissionId;
        currentStudent.FIRSTNAME = stripQuotesAndTrim (firstName);
        currentStudent.LASTNAME  = stripQuotesAndTrim (lastName);
        studentVector.add (currentStudent);
        
        // worth checking if there is name duplication in slideroom!
      }

      // fetch and concatenate ratings.
      if (currentStudent != null) {

        int portfolioRating = -1;
        int interviewRating = -1;
        String comment = ""; 
        String rater = ""; 

        int raterNameIndex       = 16;
        int commmentIndex        = 18;
        int portfolioRatingIndex = 19;
        int interviewRatingIndex = 20; 

        rater = aLineElements[raterNameIndex];
        comment = aLineElements[commmentIndex];

        try {
          portfolioRating = Integer.parseInt(aLineElements[portfolioRatingIndex]);
        } 
        catch (NumberFormatException e) {
          ;
        }

        try {
          interviewRating = Integer.parseInt(aLineElements[interviewRatingIndex]);
        } 
        catch (NumberFormatException e) {
          ;
        }

        boolean bOnCampus = false;
        Rating aRating = new Rating (portfolioRating, interviewRating, comment, rater, bOnCampus, currentStudent);
        currentStudent.addRating( aRating);

        // add Raters
        if (raters.containsKey(rater)) {
          Rater aRater = (Rater) raters.get(rater);
          //aRater.addRatings (portfolioRating, interviewRating);
          aRater.addRating (aRating); 
        } 
        else {
          Rater aRater1 = new Rater(rater);
          // aRater1.addRatings (portfolioRating, interviewRating);
          aRater1.addRating (aRating); 
          raters.put (aRater1.name, aRater1);
        }
      }
    }
  }
}

