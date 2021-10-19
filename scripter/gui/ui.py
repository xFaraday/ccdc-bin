#!/usr/bin/python

import curses  # curses is the interface for capturing key presses on the menu, os launches the files
import os
import sys
from core.engine import Engine


class Menu:

    def __init__(self):
        self.window = curses.initscr()  # initializes a new window for capturing key presses
        curses.noecho()  # Disables automatic echoing of key presses (prevents program from input each key twice)
        curses.cbreak()
        curses.start_color()  # Lets you use colors when highlighting selected menu option
        self.window.keypad(1)  # Capture input from keypad
        curses.curs_set(0)

        # Sets up color pair #1, it does black text with white background
        curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_WHITE)
        # the coloring for a highlighted menu option
        highlighted = curses.color_pair(1)

    # This function displays the appropriate menu and returns the option selected

    def run(self, menu, parent):
        # work out what text to display as the last menu option
        if parent is None:
            lastoption = 'Exit'
        else:
            lastoption = 'Return to %s menu' % parent['title']

        optioncount = len(menu['options'])  # how many options in this menu

        idx = 0  # idx is the index of the hightlighted menu option.  Every time run is called, position returns to 0, when run ends the position is returned and tells the program what option has been selected
        oldpos = None  # used to prevent the self.window being redrawn every time
        x = None  # control for while loop, let's you scroll through options until return key is pressed then returns idx to program

        # Loop until return key is pressed
        while x != ord('\n'):
            if idx != oldpos:
                oldpos = idx

                # clears previous self.window on key press and updates display based on idx
                self.window.clear()
                self.window.border(0)

                # Title for this menu
                self.window.addstr(2, 2, menu['title'], curses.A_STANDOUT)

                # Subtitle for this menu
                self.window.addstr(4, 2, menu['subtitle'], curses.A_BOLD)

                # Display all the menu items, showing the 'idx' item highlighted
                for index in range(optioncount):
                    textstyle = curses.A_NORMAL
                    if idx == index:
                        textstyle = curses.color_pair(1)
                    self.window.addstr(
                        5 + index, 4, '%d - %s' % (index + 1, menu['options'][index]['title']), textstyle)

                # Now display Exit/Return at bottom of menu
                textstyle = curses.A_NORMAL
                if idx == optioncount:
                    textstyle = curses.color_pair(1)
                self.window.addstr(5 + optioncount, 4, '%d - %s' %
                                   (optioncount + 1, lastoption), textstyle)
                self.window.refresh()

            x = self.window.getch()  # Gets user input

            if x >= ord('1') and x <= ord(str(optioncount + 1)):
                # convert keypress back to a number, then subtract 1 to get index
                idx = x - ord('0') - 1
            elif x == 258:  # down arrow
                if idx < optioncount:
                    idx += 1
                else:
                    idx = 0
            elif x == 259:  # up arrow
                if idx > 0:
                    idx += -1
                else:
                    idx = optioncount
            elif x != ord('\n'):
                curses.flash()
        return idx

    # Intrprets the given Menu Data
    def interpret(self, menu, parent=None):
        optioncount = len(menu['options'])
        exiting = False
        while not exiting:  # Loop until the user exits the menu
            getin = self.run(menu, parent)
            if getin == optioncount:
                exiting = True
            elif menu['options'][getin]['type'] == 'command':
                menu['options'][getin]['command'](
                    menu['options'][getin]['title'])
            elif menu['options'][getin]['type'] == 'menu':
                # display the submenu
                self.interpret(menu['options'][getin], menu)


menu_data = {
    "title": "Serial Scripter",
    "type": "menu",
    "subtitle": "Please selection an option...",
    "options": [
        {
            "title": "Ansible",
            "type": "menu",
            "subtitle": "Please selection an option...",
            "options": [
                {
                    "title": "Scripts Transfer",
                    "type": "command"
                },
                {
                    "title": "Execute",
                    "type": "menu",
                    "subtitle": "Please selection a host...",
                    "options": Engine.Ansible.get_hosts()
                },
                {
                    "title": "Results",
                    "type": "command"
                }
            ]
        },
        {
            "title": "Generate Host File List",
            "type": "command"
        },
        {
            "title": "Scripts",
            "type": "command"
        }
    ]
}


def start():
    try:
        Menu().interpret(menu_data)
    except:
        curses.endwin()
        print("ERROR: Please Restart Application")
        sys.exit(1)
    curses.endwin()
