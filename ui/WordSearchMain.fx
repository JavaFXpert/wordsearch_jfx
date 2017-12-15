/*
 *  WordSearchMain.fx - The main program in the Word Search Puzzle Builder
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */

package wordsearch_jfx.ui;

import javafx.ui.*;
import java.lang.System;
import wordsearch_jfx.model.WordGridModel;

var wgModel = new WordGridModel(9, 9);

var wsHandlers = WordSearchHandlers {
  wgModel:wgModel
};

var wordGridView = WordGridView {
  wsHandlers: wsHandlers
  wgModel: wgModel
};

var wordListsView = WordListsView {
  wsHandlers: wsHandlers
  border: 
    EmptyBorder {
      top: 30
      left: 30
      bottom: 30
      right: 30
    }
  wgModel: wgModel
};

wgModel.wordGridView = wordGridView;
wgModel.wordListsView = wordListsView;
wsHandlers.dlgOwner = wordListsView;

Frame {
  title: "Word Search Puzzle Builder in JavaFX Script"
  width: 750
  height: 450
  onClose: operation() {
    System.exit(0);
  }
  visible: true
  menubar: MenuBar {
    menus: [
      Menu {
        text: "Grid"
        mnemonic: G
        items: [
          MenuItem {
            text: "Place Word..."
            mnemonic: P
            accelerator: {
              modifier: CTRL
              keyStroke: P
            }
            enabled: bind not wgModel.fillLettersOnGrid
            action: operation() {
              wsHandlers.gridPlaceWord();
            }
          },
          MenuItem {
            text: "Place Word Randomly..."
            mnemonic: R
            accelerator: {
              modifier: CTRL
              keyStroke: R
            }
            enabled: bind not wgModel.fillLettersOnGrid
            action: operation() {
              wsHandlers.gridPlaceWordRandomly();
            }
          },
          MenuItem {
            text: "Place All Words Randomly..."
            mnemonic: A
            accelerator: {
              modifier: ALT
              keyStroke: P
            }
            enabled: bind not wgModel.fillLettersOnGrid
            action: operation() {
              wsHandlers.gridPlaceAllWords();
            }
          },
          MenuSeparator,
          MenuItem {
            text: "Unplace Word..."
            mnemonic: U
            accelerator: {
              modifier: CTRL
              keyStroke: U
            }
            enabled: bind not wgModel.fillLettersOnGrid
            action: operation() {
              wsHandlers.gridUnplaceWord();
            }
          },
          MenuItem {
            text: "Unplace All Words..."
            mnemonic: L
            accelerator: {
              modifier: ALT
              keyStroke: U
            }
            enabled: bind not wgModel.fillLettersOnGrid
            action: operation() {
              wsHandlers.gridUnplaceAllWords();
            }
          },
          CheckBoxMenuItem {
            text: "Show Fill Letters"
            selected: bind wgModel.fillLettersOnGrid
            mnemonic: F
            accelerator: {
              modifier: CTRL
              keyStroke: F
            }
          },
          MenuSeparator,
          MenuItem {
            text: "Exit"
            mnemonic: X
            action: operation() {
              System.exit(0);
            }
          },
        ]
      },
      Menu {
        text: "WordList"
        mnemonic: W
        items: [
          MenuItem {
            text: "Add Word"
            mnemonic: W
            accelerator: {
              keyStroke: INSERT
            }
            action: operation() {
              wsHandlers.wordListAddWord();
            }
          },
          MenuItem {
            text: "Delete Word"
            mnemonic: D
            accelerator: {
              keyStroke: DELETE
            }
            enabled: bind not wgModel.fillLettersOnGrid
            action: operation() {
              wsHandlers.wordListDeleteWord();
            }
          }
        ]
      },
      Menu {
        text: "Help"
        mnemonic: H
        items: [
          MenuItem {
            text: "About Word Search Puzzle Builder..."
            mnemonic: A
            action: operation() {
              MessageDialog {
                title: "About Word Search Puzzle Builder"
                message: "A JavaFX Script example program by James L. Weaver
(jim.weaver at jmentor dot com).  Last revised July 2007."
                messageType: INFORMATION
                visible: true 
              }
            }
          }
        ]
      }
    ]
  }
  content:
    BorderPanel {
      top:
        ToolBar {
          floatable: true
          border:
            EtchedBorder {
              style:RAISED
            }
          buttons: [
            Button {
              icon: 
                Image {
                  url: "file:resources/place_word.gif"
                }
              toolTipText: "Place word on grid"
              enabled: bind not wgModel.fillLettersOnGrid
              action: operation() {
                wsHandlers.gridPlaceWord();
              }
            },
            Button {
              icon: 
                Image {
                  url: "file:resources/place_random.gif"
                }
              toolTipText: "Place word randomly on grid"
              enabled: bind not wgModel.fillLettersOnGrid
              action: operation() {
                wsHandlers.gridPlaceWordRandomly();
              }
            },
            Button {
              icon: 
                Image {
                  url: "file:resources/unplace_word.gif"
                }
              toolTipText: "Unplace (remove) word from grid"
              enabled: bind not wgModel.fillLettersOnGrid
              action: operation() {
                wsHandlers.gridUnplaceWord();
              }
            },
            Button {
              icon: 
                Image {
                  url: "file:resources/add_word.gif"
                }
              toolTipText: "Add word to word list"
              action: operation() {
                wsHandlers.wordListAddWord();
              }
            }
          ]
        }
      center:
        Box {
          orientation: HORIZONTAL
          content: [
            Canvas {
              content: bind wgModel.wordGridView
            },
            BorderPanel {
              center: bind wgModel.wordListsView
            }
          ]
        }    
    }    
}
