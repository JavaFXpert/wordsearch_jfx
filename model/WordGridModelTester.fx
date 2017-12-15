/*
 *  WordGridModelTester.fx - The main program in the Word Search Puzzle Builder
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */

package wordsearch_jfx.model;

import javafx.ui.*;
import java.lang.System;

class WordGridModelTester {
  attribute wordGridModel:WordGridModel;
  operation runTest();
  operation printGrid();
}

attribute WordGridModelTester.wordGridModel = new WordGridModel(7, 6);

trigger on not assert assertion {
    println("Assertion failed!");
}

trigger on assert assertion {
    println("Assertion passed!");
}

operation WordGridModelTester.runTest() {
  wordGridModel.addWord("red");
  wordGridModel.addWord("orange");
  wordGridModel.addWord("yellow");
  wordGridModel.addWord("green");
  wordGridModel.addWord("blue");
  wordGridModel.addWord("indigo");
  wordGridModel.addWord("violet");

  // Iterate over the unplaced WordEntry instances and print them out
  for (wge in wordGridModel.unplacedGridEntries) {
    System.out.println(wge);
  }

  var placed;

  // Try to place a word. It is expected to be successful.
  placed = wordGridModel.placeWordSpecific("red", 4, 3, 
                                           DIAG_UP:WordOrientation.id);
  System.out.println("It is {placed} that red was placed. Expected true.");

  // Try to place a word with a letter intersecting the same letter in another
  // word. Iin this case, we're trying to place "green" intersecting with an
  // "e" in "red"
  placed = wordGridModel.placeWordSpecific("GREEN", 3, 2, 
                                           HORIZ:WordOrientation.id);
  System.out.println("It is {placed} that green was placed. Expected true.");

  // Try to place a word that isn't in the unplaced word list
  placed = wordGridModel.placeWordSpecific("black", 0, 0, 
                                           VERT:WordOrientation.id);
  System.out.println("It is {placed} that black was placed. Expected false.");

  // Try to place a word. It is expected to be successful.
  placed = wordGridModel.placeWordSpecific("blue", 0, 0, 
                                           VERT:WordOrientation.id);
  System.out.println("It is {placed} that blue was placed. Expected true.");

  // Try to place a word in such a way that part of the word is outside the grid
  placed = wordGridModel.placeWordSpecific("yellow", 5, 5, 
                                           DIAG_DOWN:WordOrientation.id);
  System.out.println("It is {placed} that yellow was placed. Expected false.");

  // Try to place a word with a letter intersecting a different letter in 
  // another word (in this case, we're trying to place "indigo" intersecting with
  // a "b" in "blue"
  placed = wordGridModel.placeWordSpecific("indigo", 0, 0, 
                                           HORIZ:WordOrientation.id);
  System.out.println("It is {placed} that indigo was placed. Expected false.");

  // Try to place a word randomly. It is expected to be successful if there is
  // any available place on the grid to place it (which there should be at this
  // point). Use the assert statement this time.  Let's pretend that we expect
  // it to return false so that we'll see the assertion fail.
  System.out.println("Calling placeWord with 'orange', should return false");
  assert wordGridModel.placeWord("orange") == false;

  // Try to place a word randomly that already is on the grid.
  // Use the assert statement this time
  System.out.println("Calling placeWord with 'red', should return false");
  assert wordGridModel.placeWord("red") == false;
  
  printGrid();
  
  // Cause the fill letters to appear on the grid
  System.out.println("Setting fillLettersOnGrid to 'true'");
  wordGridModel.fillLettersOnGrid = true;
  printGrid();
}

operation WordGridModelTester.printGrid() {
  System.out.println("--------");
  for (row in [0.. wordGridModel.rows - 1]) {
    System.out.print("|");
    for (column in [0.. wordGridModel.columns - 1]) {
      System.out.print(wordGridModel.gridCells
        [row * wordGridModel.columns + column].cellLetter);
    }
    System.out.println("|");
  }
  System.out.println("--------");
}

var tester = WordGridModelTester{};
tester.runTest();

