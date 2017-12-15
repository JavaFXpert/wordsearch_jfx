/*
 *  WordSearchHandlers.fx - Handles the events triggered by the user (that
 *                          require additional input from the user) while
 *                          interacting with the UI of the Word Search Puzzle
 *                          Builder
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */

package wordsearch_jfx.ui;

import javafx.ui.*;

import wordsearch_jfx.model.WordGridModel;
import wordsearch_jfx.model.WordGridCell;
import wordsearch_jfx.model.WordOrientation;

import java.lang.NumberFormatException;
import java.lang.Math;
import java.lang.System;
import java.util.Scanner;

public class WordSearchHandlers {
  attribute wgModel:WordGridModel;
  attribute dlgOwner:UIElement;

  private attribute dlg:Dialog;

  operation gridPlaceWord();
  operation gridPlaceWordRandomly();
  operation gridPlaceAllWords();
  operation gridUnplaceWord();
  operation gridUnplaceAllWords();
  operation wordListAddWord();
  operation wordListDeleteWord();

  private operation convertStringToInteger(str:String):Integer;  
}

operation WordSearchHandlers.gridPlaceWord() {
  if (wgModel.selectedUnplacedWordIndex < 0) {
    MessageDialog {
      title: "Word not selected"
      message: "Please select a word from the Unplaced Word list"
      messageType: ERROR
      visible: true
    }
    return;
  }
  else {
    wgModel.selectedDirection = HORIZ:WordOrientation.id;
    wgModel.rowStr = "";
    wgModel.columnStr = "";
    dlg = Dialog {
      modal: true
      owner: dlgOwner
      title: "Place Word on Grid"
      content:
        Box {
          orientation: VERTICAL
          content: [
            GroupPanel {
              var wordRow = Row { alignment: BASELINE }
              var rowNumRow = Row { alignment: BASELINE }
              var columnNumRow = Row { alignment: BASELINE }
              var labelsColumn = Column {
                alignment: TRAILING
              }
              var fieldsColumn = Column {
                alignment: LEADING
                resizable: true
              }
              rows: [wordRow, rowNumRow, columnNumRow]
              columns: [labelsColumn, fieldsColumn]
              content: [
                SimpleLabel {
                  row: wordRow
                  column: labelsColumn
                  text: "Word:"
                },
                SimpleLabel {
                  row: wordRow
                  column: fieldsColumn
                  text: wgModel.selectedUnplacedWord
                },
                SimpleLabel {
                  row: rowNumRow
                  column: labelsColumn
                  text: "Row (0-{wgModel.rows - 1}):"
                },
                TextField {
                  row: rowNumRow
                  column: fieldsColumn
                  columns: 3
                  value: bind wgModel.rowStr
                },  
                SimpleLabel {
                  row: columnNumRow
                  column: labelsColumn
                  text: "Column (0-{wgModel.columns - 1}):"
                },
                TextField {
                  row: columnNumRow
                  column: fieldsColumn
                  columns: 3
                  value: bind wgModel.columnStr
                }
              ]  
            },
            GridPanel {
              border:
                TitledBorder {
                  title: "Direction"
                }
              rows: 4
              columns: 1
              var directionButtonGroup = ButtonGroup {
                selection: bind wgModel.selectedDirection
              }
              cells: [
                RadioButton {
                  buttonGroup: directionButtonGroup
                  text: "Horizontal"
                },
                RadioButton {
                  buttonGroup: directionButtonGroup
                  text: "Diagonal Down"
                },
                RadioButton {
                  buttonGroup: directionButtonGroup
                  text: "Vertical"
                },
                RadioButton {
                  buttonGroup: directionButtonGroup
                  text: "Diagonal Up"
                }
              ]
            }
              
          ]
        }
    buttons: [
      Button {
        text: "OK"
        defaultButton: true
        action:
          operation() {
            var row = 0;
            var column = 0;
            
            try {
              row = convertStringToInteger(wgModel.rowStr);
              column = convertStringToInteger(wgModel.columnStr);
            }
            catch (nfe:NumberFormatException) {
              row = -1;  // Force row to be an invalid number
            }
            if (row < 0 or
                row > wgModel.rows - 1 or
                column < 0 or
                column > wgModel.columns - 1) { 
              
              <<javax.swing.JOptionPane>>.showMessageDialog(null,
                "Please enter valid row and column numbers",
                "Invalid row or column number",
                <<javax.swing.JOptionPane>>.INFORMATION_MESSAGE);
              wgModel.selectedDirection = HORIZ:WordOrientation.id;
              wgModel.rowStr = "";
              wgModel.columnStr = "";
            }
            else {
              // User entered valid number of rows and columns
              if (wgModel.placeWordSpecific(wgModel.selectedUnplacedWord,
                                            row,
                                            column,
                                            wgModel.selectedDirection)) {
                dlg.hide();
              }
              else {
                MessageDialog {
                  owner: dlg
                  title: "Placement Error"
                  message: "Couldn't place word at specified location"
                  messageType: ERROR
                  visible: true
                }
              }
            }
          }
      },
      Button {
        text: "Cancel"
        defaultCancelButton: true
        action:
          operation() {
            dlg.hide();
            return;
          }
      }
    ]
  };
  dlg.show();
  }
}

operation WordSearchHandlers.gridPlaceWordRandomly() {
  if (wgModel.selectedUnplacedWordIndex < 0) {
    MessageDialog {
      title: "Word not selected"
      message: "Please select a word from the Unplaced Word list"
      messageType: ERROR
      visible: true
    }
    return;
  }
  else {
    var resp = <<javax.swing.JOptionPane>>.showConfirmDialog(null,
      "Place Word: {wgModel.selectedUnplacedWord}?",
      "Place Word Randomly on Grid",
      <<javax.swing.JOptionPane>>.OK_CANCEL_OPTION,
      <<javax.swing.JOptionPane>>.QUESTION_MESSAGE);
  
    if (resp == <<javax.swing.JOptionPane>>.OK_OPTION) {
      if (not wgModel.placeWord(wgModel.selectedUnplacedWord)) {
        MessageDialog {
          owner: dlg
          title: "Placement Error"
          message: "Didn't place word on grid"
          messageType: ERROR
          visible: true
        }
      }
    }
  }
}

operation WordSearchHandlers.gridPlaceAllWords() {

  var resp = <<javax.swing.JOptionPane>>.showConfirmDialog(null,
    "Are you sure that you want to place all words?",
    "Confirm",
    <<javax.swing.JOptionPane>>.YES_NO_OPTION,
    <<javax.swing.JOptionPane>>.QUESTION_MESSAGE);
    
  if (resp == <<javax.swing.JOptionPane>>.YES_OPTION) {
    for (wge in wgModel.unplacedGridEntries) {
      if (not wgModel.placeWord(wge.word)) {
        System.out.println("Word {wge.word} not placed");
        MessageDialog {
          title: "Word not placed"
          message: "Didn't place word: {wge.word}"
          messageType: INFORMATION
          visible: true
        }
      }
    }
  }
}

operation WordSearchHandlers.gridUnplaceWord() {
  if (wgModel.selectedPlacedWordIndex < 0) {
    MessageDialog {
      title: "Word not selected"
      message: "Please select a word from the Placed Word list"
      messageType: INFORMATION
      visible: true
    }
    return;
  }
  else {
    var resp = <<javax.swing.JOptionPane>>.showConfirmDialog(null,
      "Unplace Word: {wgModel.selectedPlacedWord}?",
      "Unplace Word from Grid",
      <<javax.swing.JOptionPane>>.OK_CANCEL_OPTION,
      <<javax.swing.JOptionPane>>.QUESTION_MESSAGE);
  
    if (resp == <<javax.swing.JOptionPane>>.OK_OPTION) {
      wgModel.unplaceWord(wgModel.selectedPlacedWord);
    }
  }
}

operation WordSearchHandlers.gridUnplaceAllWords() {
  var resp = <<javax.swing.JOptionPane>>.showConfirmDialog(null,
    "Are you sure that you want to unplace all words?",
    "Confirm",
    <<javax.swing.JOptionPane>>.YES_NO_OPTION,
    <<javax.swing.JOptionPane>>.QUESTION_MESSAGE);

  if (resp == <<javax.swing.JOptionPane>>.YES_OPTION) {
    wgModel.unplaceGridEntries();
  }
}

operation WordSearchHandlers.wordListAddWord() {
  wgModel.newWord = "";
  dlg = Dialog {
    modal: true
    owner: dlgOwner
    title: "Add Word to Word List"
    content:
      GroupPanel {
        var newWordRow = Row { alignment: BASELINE }
        var labelsColumn = Column {
          alignment: TRAILING
        }
        var fieldsColumn = Column {
          alignment: LEADING
          resizable: true
        }
        var tf = TextField {
          row: newWordRow
          column: fieldsColumn
          columns: 15
        }  
        rows: [newWordRow]
        columns: [labelsColumn, fieldsColumn]
        content: [
          SimpleLabel {
            row: newWordRow
            column: labelsColumn
            text: "New Word:"
          },
          TextField {
            row: newWordRow
            column: fieldsColumn
            columns: 15
            value: bind wgModel.newWord
          }  
        ]
      }
    buttons: [
      Button {
        text: "OK"
        defaultButton: true
        action:
          operation() {
            var word = wgModel.newWord.trim();
            if (word.length() < 3) {
              MessageDialog {
                title: "Input Error"
                message: "Word must contain at least 3 letters"
                messageType: ERROR
                visible: true
              }
              wgModel.newWord = "";
            }
            else if (word.indexOf(SPACE:String) >= 0) {
              MessageDialog {
                owner: dlg
                title: "Input Error"
                message: "Word must not contain any spaces"
                messageType: ERROR
                visible: true
              }
              wgModel.newWord = "";
            }
            else {
              if (wgModel.addWord(wgModel.newWord)) {
                dlg.hide();
              }
              else {
                MessageDialog {
                  owner: dlg
                  title: "Input Error"
                  message: "{wgModel.newWord} is already in the word list"
                  messageType: ERROR
                  visible: true
                }
                wgModel.newWord = "";
              }
            }
          }
      },
      Button {
        text: "Cancel"
        defaultCancelButton: true
        action:
          operation() {
            dlg.hide();
            return;
          }
      }
    ]
  };
  dlg.show();
}

operation WordSearchHandlers.wordListDeleteWord() {
  var selWord = "";
  if (wgModel.selectedUnplacedWordIndex >= 0) {
    selWord = wgModel.selectedUnplacedWord;
  }
  else if (wgModel.selectedPlacedWordIndex >= 0) {
    selWord = wgModel.selectedPlacedWord;
  }
  else {
    MessageDialog {
      title: "Word not selected"
      message: "Please select word from the Unplaced Word or Placed Word list"
      messageType: ERROR
      visible: true
    }
    return;
  }
  var resp = <<javax.swing.JOptionPane>>.showConfirmDialog(null,
    "Delete Word: {selWord}?",
    "Delete Word from Word List",
    <<javax.swing.JOptionPane>>.OK_CANCEL_OPTION,
    <<javax.swing.JOptionPane>>.QUESTION_MESSAGE);
  
  if (resp == <<javax.swing.JOptionPane>>.OK_OPTION) {
    wgModel.deleteWord(selWord);
  }
}

operation WordSearchHandlers.convertStringToInteger(str) {
  var scanner = new Scanner(str);
  if (scanner.hasNextInt()) {
    return new Scanner(str).nextInt();
  }
  else {
    throw new NumberFormatException("{str} is not a number");
  }
}  
