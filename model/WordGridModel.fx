/*
 *  WordGridModel.fx - The "model" behind the "views" in the Word Search Puzzle
 *                     Builder
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */

package wordsearch_jfx.model;

import javafx.ui.*;
import java.lang.Math;
import wordsearch_jfx.ui.WordGridRect;
import wordsearch_jfx.ui.WordGridView;
import wordsearch_jfx.ui.WordListsView;

class WordGridModel {
  // Number of rows in the grid
  attribute rows: Integer; 

  // Number of columns in the grid
  attribute columns: Integer;

  // Row and column to operate on in the grid
  // These are bound to TextFields
  public attribute rowStr: String; 
  public attribute columnStr: String;

  // A word to be added to the unplaced word list, and is bound to a TextField
  public attribute newWord:String;

  // Bound to word direction selected in dialog box(es)
  public attribute selectedDirection:Integer;

  // Related to the unplaced ListBox and unplaced word grid entries
  public attribute unplacedListBox:ListBox;
  public attribute selectedUnplacedWordIndex:Integer;
  public attribute selectedUnplacedWord:String;
  public attribute unplacedGridEntries:WordGridEntry*;

  // Related to the placed ListBox and placed word grid entries
  public attribute placedListBox:ListBox;
  public attribute selectedPlacedWordIndex:Integer;
  public attribute selectedPlacedWord:String;
  public attribute placedGridEntries:WordGridEntry*; 

  // References to views of the model
  public attribute wordGridView:WordGridView;
  public attribute wordListsView:WordListsView;

  // Array of objects, each of which represent a cell on the word grid
  public attribute gridCells:WordGridCell*;  

  // Holds the state of whether the fill letters are on the grid,
  // and changing this value causes the fill letters to appear or
  // dissapear from the grid.
  public attribute fillLettersOnGrid:Boolean; 

  // Operations and Functions
  public operation WordGridModel(rows:Integer, columns:Integer);
  public operation placeWord(word:String):Boolean;
  public operation placeWordSpecific(word:String, row:Integer, column:Integer, 
                                     direction:Integer):Boolean;
  public operation canPlaceWordSpecific(word:String, row:Integer, 
                                        column:Integer, direction:Integer,
                                        cellAppearance:WordGridRect):Boolean;
  public operation selectPlacedWord(word:String);
  public operation unplaceWord(word:String):Boolean;
  public operation unplaceGridEntries();
  public operation addWord(word:String):Boolean;
  public operation deleteWord(word:String):Boolean;
  public operation highlightWordsOnCell(cellNum:Integer);

  private operation initializeGrid();
  private function getLetter(row:Integer, column:Integer):String;
  private operation copyFillLettersToGrid();
  private operation refreshWordsOnGrid();
  private operation placeWordGridEntry(wge:WordGridEntry);
  private operation getXIncr(direction:Integer):Integer;
  private operation getYIncr(direction:Integer):Integer;
  private operation getGridEntryByWord(word:String):WordGridEntry;
}

// Constant that indicates that an operation
// pertains to no cell.  Used as an argument to highlightWordsOnCell()
NO_CELL:Integer = -1;

// Triggers
/**
 * Fills with random letters (or removes them from) all of the grid cells that
 * aren't being occupied by placed words. These random letters are generated
 * when the instance of WordGridModel is created.
 */
trigger on WordGridModel.fillLettersOnGrid = onGrid {
  if (onGrid) {
    initializeGrid();
    copyFillLettersToGrid();
    refreshWordsOnGrid();
    fillLettersOnGrid = true;
  }
  else {
    initializeGrid();
    refreshWordsOnGrid();
    fillLettersOnGrid = false;
  }
}

/**
 * Updates the uplaced selected word in the model based upon what cell
 * is selected in the unplaced words ListBox
 */
trigger on WordGridModel.selectedUnplacedWordIndex[oldValue] = newValue {
  selectedUnplacedWord = unplacedListBox.cells[selectedUnplacedWordIndex].text;
}

/**
 * Updates the uplaced selected word in the model based upon what cell
 * is selected in the unplaced words ListBox
 */
trigger on WordGridModel.selectedPlacedWordIndex = newIndex {
  selectedPlacedWord = placedListBox.cells[newIndex].text;
}
         
/**
 * A method that acts as a constructor for the WordGridModel class
 */
operation WordGridModel.WordGridModel(rows, columns) {
  this.rows = rows;
  this.columns = columns;
  selectedPlacedWordIndex = -1;
  unplacedGridEntries = [];
  placedGridEntries = [];
  gridCells = [];
  fillLettersOnGrid = false;
  initializeGrid();
}         

/**
 * Places a word on the grid with no specified location or orientation.
 * Beginning with a random row, column, and orientation, it tries every
 * available position for a word before giving up and returning false.
 * If successful it places the word and returns true.
 */
operation WordGridModel.placeWord(word) {
  var success = false; 
  var startingRow:Integer = (Math.random() * rows).intValue();
  var startingColumn:Integer = (Math.random() * columns).intValue();
  for (y in [0.. rows - 1]) {
    for (x in [0.. columns - 1]) {
      var startingOrientId = (Math.random() * NUM_ORIENTS:Integer).intValue();
      for (d in [0.. NUM_ORIENTS:Integer - 1]) {
        var wordDirection = WordOrientation {
                              id: (startingOrientId + d) % NUM_ORIENTS:Integer
                            };
        success =  placeWordSpecific(word, 
                                     (startingRow + y) % rows,
                                     (startingColumn + x) % columns,
                                     wordDirection.id);
        if (success) {
          return true;
        }
      }
    }
  }
  return false;
}

/**
 * Places a word on the grid at a specified location and orientation. The word
 * must already be in the word list. If the word is successfully placed this
 * method sets the internal state of the associate WordGridEntry with the row,
 * column, orientation, and the fact that it is now placed. 
 */
operation WordGridModel.placeWordSpecific(word, row, column, direction) {
  // Make sure that the word is in the WordGridEntry array
  var wge = getGridEntryByWord(word);

  if (wge == null) {
    // Word not found in word lists
    return false;
  }
  else {
    if (wge.placed) {
      // Word is already placed
      return false;
    }
  }

  // Check to make sure that the word may be placed there
  if (not canPlaceWordSpecific(word, row, column, direction, 
                               DEFAULT_LOOK:WordGridRect)) {
    return false;
  }
  
  // Word can be placed, so place it now
  wge.row = row;
  wge.column = column;
  wge.direction = direction;
  placeWordGridEntry(wge);

  delete unplacedGridEntries[w | w == wge]; 
  insert wge into placedGridEntries;
  wge.placed = true;

  return true;
}

/**
 * Checks to see if a word can be placed on the grid at a specified location
 * and orientation.  It also specifies the appearance state that the cells
 * should have.
 */
operation WordGridModel.canPlaceWordSpecific(word, row, column, direction, 
                                             cellAppearance) {
  var xPos = column;
  var yPos = row;

  // amount to increment in each direction for subsequent letters
  var xIncr = 0;  
  var yIncr = 0;
  
  var canPlaceWord = true;

  // Check to make sure that the word may be placed there
  xIncr = getXIncr(direction);
  yIncr = getYIncr(direction);

  // Make all cells in the grid have the default appearance
  highlightWordsOnCell(NO_CELL:Integer);

  // Make sure that the word can be placed
  for (i in [0.. word.length() - 1]) {
    if (xPos > columns - 1 or yPos > rows - 1 or xPos < 0 or yPos <0) {
      // The word can't be placed because one of the letters is off the grid
      canPlaceWord = false;
      break;
    }
    // See if the letter being placed is either a space or the same letter
    else if ((gridCells[yPos * columns + xPos].cellLetter <> SPACE:String) and
      (gridCells[yPos * columns + xPos].cellLetter <> word.substring(i, i+1))) {
      // The word can't be placed because of a conflict with another
      // letter on the grid
      canPlaceWord = false;
    }
    if (cellAppearance == DRAGGING_LOOK:WordGridRect) {
      gridCells[yPos * columns + xPos].appearance = DRAGGING_LOOK;
    }
    else if (cellAppearance == CANT_DROP_LOOK:WordGridRect) {
      gridCells[yPos * columns + xPos].appearance = CANT_DROP_LOOK;
    }
    else if (i == 0) {
      // This is the first letter of the word
      gridCells[yPos * columns + xPos].appearance = DEFAULT_FIRST_LETTER_LOOK;
    }
    else {
      gridCells[yPos * columns + xPos].appearance = DEFAULT_LOOK;
    }
    xPos += xIncr;
    yPos += yIncr;
  }
  return canPlaceWord;  
}

/**
 * Finds and selects a given word in the placed word list
 */
operation WordGridModel.selectPlacedWord(word) {
  var selected = -1;

  for (i in [0.. sizeof placedGridEntries - 1]) {
    if (placedGridEntries[i].word.equalsIgnoreCase(word)) {
      selected = i;
      break;
    }
  }
  selectedPlacedWordIndex = selected;
}

/**
 * Unlaces a word from the grid. This doesn't remove the word from the word
 * list. It only unplaces it from the grid, marking it as not placed.
 */
operation WordGridModel.unplaceWord(word) {
  var wge = getGridEntryByWord(word);
  if (wge == null) {
    // Word not found in WordGridModel word list
    return false;
  }
  else {
    if (not wge.placed) {
      // Word is already unplaced
      return false;
    }
  }
  var xPos = wge.column;
  var yPos = wge.row;
  var xIncr = getXIncr(wge.direction);
  var yIncr = getYIncr(wge.direction);

  var i = 0;
  while (i < word.length()) {
    gridCells[yPos * columns + xPos].cellLetter = SPACE:String;
    
    // Dissasociate this WordGridEntry with the cell on the grid view
    var wges = gridCells[yPos * columns + xPos].wordEntries;
    delete wges[w | w == wge];
    
    xPos += xIncr;
    yPos += yIncr;
    i++;
  }
  insert wge into unplacedGridEntries;
  delete placedGridEntries[w | w == wge]; 
  wge.placed = false;
  
  initializeGrid();
  refreshWordsOnGrid();
  return true;
}

/**
 * Unplaces all of the words from the grid
 */
operation WordGridModel.unplaceGridEntries() {
  for (wge in placedGridEntries) {
    unplaceWord(wge.word);
  }
}

/**
 * Adds a word to the word list.  The word list consists of all of the words
 * that are available to appear on the grid.  Each word is represented by its
 * own instance of the WordGridEntry class.  Note that the added word is not
 * automatically placed on the grid. 
 */
operation WordGridModel.addWord(word) {
  if (getGridEntryByWord(word) == null) {
    var wge = WordGridEntry {
      word: word
    };
    insert wge into unplacedGridEntries;
    return true;
  }
  else {
    return false;
  }
}

/**
 * Deletes a word from the word list.  The word list consists of all of the
 * words that are available to appear on the grid.  Each word is represented 
 * by its own instance of the WordGridEntry class.
 */
operation WordGridModel.deleteWord(word) {
  var wge = getGridEntryByWord(word);
  if (wge <> null) {
    if (wge.placed) {
      unplaceWord(word);
    }
    delete unplacedGridEntries[w | w == wge];
    return true;
  }
  else {
    return false;
  }
}

/**
 * Set the highlightCell attribute of the model for every letter of
 * every word that has one if its letters in a given cell.
 */
operation WordGridModel.highlightWordsOnCell(cellNum) {
  var xPos;
  var yPos;
  var xIncr;
  var yIncr;

  for (i in [0.. sizeof gridCells - 1]) {
    gridCells[i].appearance = DEFAULT_LOOK:WordGridRect;
  }
  if (cellNum <> NO_CELL:Integer) {
    for (wge in gridCells[cellNum].wordEntries) {
      xPos = wge.column;
      yPos = wge.row;
      xIncr = getXIncr(wge.direction);
      yIncr = getYIncr(wge.direction);
      for (i in [0.. wge.word.length()- 1]) {
        if (i == 0) {
          gridCells[yPos * columns + xPos].appearance = 
            SELECTED_FIRST_LETTER_LOOK:WordGridRect;
        }
        else {
          gridCells[yPos * columns + xPos].appearance = 
            SELECTED_LOOK:WordGridRect;
        }
        xPos += xIncr;
        yPos += yIncr;
      }
    }
  }
}

/**
 * Fills the grid (two-dimensional array that stores the word search puzzle
 * letters) with spaces, as well as references to an object that
 * contains an array of the WordGridEntry instances that are associated
 * with a given cell in the grid.
 */
operation WordGridModel.initializeGrid() {
  if (sizeof gridCells == 0) {
    for (i in [0.. (rows * columns) - 1]) {
      insert WordGridCell{} into gridCells;
    }
  }
  else {
    for (i in [0.. sizeof gridCells - 1]) {
      gridCells[i].cellLetter = SPACE:String;

      gridCells[i].wordEntries = [];
    }
  }
}

/**
 * Returns the letter at a specfied row and column of the grid.
 */
function WordGridModel.getLetter(row, column) {
  return gridCells[row * columns + column].cellLetter;
}

/**
 * Copies the randomly generated fill letters from the array in which they are
 * stored into the array that stores the word search puzzle letters.
 */
operation WordGridModel.copyFillLettersToGrid() {
  for (i in [0.. sizeof gridCells - 1]) {
    gridCells[i].cellLetter = gridCells[i].fillLetter;
  } 
}

/**
 * This method refreshes the grid with the words that have already been placed.
 * This would be called, for example, when the user requests that 
 * "fill letters" be shown, because after the grid is filled with 
 * fill letters, the placed words need to be put back on the grid.
 */
operation WordGridModel.refreshWordsOnGrid() {
  for (i in [0..sizeof placedGridEntries - 1]) {
    placeWordGridEntry(placedGridEntries[i]);
  }
}

/**
 * This method takes a WordGridEntry and places each letter in the word onto
 * the grid, according to the position and direction stored in the WordGridEntry
 */
operation WordGridModel.placeWordGridEntry(wge) {
  var xPos = wge.column;
  var yPos = wge.row;
  var xIncr = getXIncr(wge.direction);
  var yIncr = getYIncr(wge.direction);
  var word = wge.word;
  for (i in [0.. word.length()- 1]) {
    gridCells[yPos * columns + xPos].cellLetter = word.substring(i, i + 1);
    
    // Associate this WordGridEntry with the cell on the grid view
    insert wge into gridCells[yPos * columns + xPos].wordEntries;
    
    xPos += xIncr;
    yPos += yIncr;
  }
}

/**
 * This method calculates the number that should be added to the column in
 * which the previous letter was placed, in order to calculate the column in
 * which next letter should be placed.  This is based upon the direction that
 * the word is to be placed. For example, this method would return 1 if the word
 * is to be placed horizontally, but 0 if it is to be placed vertically.
 */
operation WordGridModel.getXIncr(direction) {
  var xIncr:Integer = 1;
  if (direction == VERT:WordOrientation.id) {
    xIncr = 0;
  }
  return xIncr;
}

/**
 * This method calculates the number that should be added to the row in
 * which the previous letter was placed, in order to calculate where the
 * next letter should be placed. For example, this method would return 0 if
 * the word is to be placed horizontally, but 1 if it is to be placed vertically.
 */
operation WordGridModel.getYIncr(direction) {
  var yIncr:Integer = 1;
  if (direction == HORIZ:WordOrientation.id) {
    yIncr = 0;
  }
  else if (direction == DIAG_UP:WordOrientation.id) {
    yIncr = -1;
  }
  return yIncr;
}

/**
 * Returns a WordGridEntry that contains the passed-in word.
 */
operation WordGridModel.getGridEntryByWord(word) {
  var wges;
  wges = foreach (entry in unplacedGridEntries
           where entry.word.equalsIgnoreCase(word))
    entry;
  if (sizeof wges > 0) {
    return wges[0];
  }
  
  wges = foreach (entry in placedGridEntries
           where entry.word.equalsIgnoreCase(word))
    entry;
  if (sizeof wges > 0) {
    return wges[0];
  }
  else {
    return null;
  }
}

