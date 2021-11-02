from simple_term_menu import TerminalMenu


class Menu:
    """
    A class that uses simple_term_menu's TerminalMenu object to create a menu based on 
    a list of tuples
    """

    def __init__(self, title: str, options: list,
                 cursor=">", cursor_style=("fg_green", "bold"),
                 style=("bg_black", "fg_gray")) -> None:
        """
        :param str cursor: Define another cursor or disable it (None). The \
            default cursor is ">"
        :param str cursor_style: The style of the shown cursor. The default \
            style is ("fg_red", "bold")
        :param str style: The style of the selected menu entry. The default \
            style is ("standout",)
        :ivar str title: the title of the menu
        :ivar list[str] items: A list of the options to be displayed on the \
            menu
        :ivar list[tuple[str, function]] switch: A case-switch for quickly \
            dealing with the function attatched with to the selected option
        :ivar :class:'TerminalMenu<simple_term_menu.TerminalMenu>' menu: The \
            menu's TerminalMenu object
        """

        self.title = title
        self.items = self.set_items(options)

        self.switch = options

        self.menu = TerminalMenu(
            menu_entries=self.items,
            title=self.title,
            menu_cursor=cursor,
            menu_cursor_style=cursor_style,
            menu_highlight_style=style,
            cycle_cursor=True,
            clear_screen=True,
        )

    @staticmethod
    def set_items(options) -> list:
        """
        Generates a list of menu options compatable with the TerminalMenu object

        :param list[tuple[str, function]]
        :rtype: list[str]
        """

        r_list = list()
        for option in options:
            r_list.append(option[0])
        return r_list

    def setup(self) -> None:
        pass

    def show(self) -> None:
        """
        Shows menu
        """

        self.menu.show()

    def start(self) -> None:
        """
        Starts the main menu loop
        """
        menu_exit = False
        while not menu_exit:
            selection = self.menu.show()

            if selection == len(self.items)-1:
                menu_exit = True
            else:
                self.switch[selection][1]()


class MultiSelectMenu(Menu):
    def __init__(self, title: str, options: list, cursor=">", cursor_style=("fg_green", "bold"), style=("bg_black", "fg_gray")) -> None:
        """
        :param str cursor: Define another cursor or disable it (None). The  \
            default cursor is ">"
        :param str cursor_style: The style of the shown cursor. The default \
            style is ("fg_red", "bold")
        :param str style: The style of the selected menu entry. The default \
            style is ("standout",)
        :ivar str title: the title of the menu
        :ivar list[str] items: A list of the options to be displayed on the \
            menu
        :ivar list[tuple[str, function]] switch: A case-switch for quickly  \
            dealing with the function attatched with to the selected option
        :ivar :class:'TerminalMenu<simple_term_menu.TerminalMenu>' menu:    \
            The menu's TerminalMenu object
        """

        self.title = title
        self.items = self.set_items(options)

        self.switch = options

        self.menu = TerminalMenu(
            menu_entries=self.items,
            title=self.title,
            menu_cursor=cursor,
            menu_cursor_style=cursor_style,
            status_bar_style=("fg_gray", "bg_black"),
            multi_select_cursor_style=("fg_green", "bold"),
            multi_select_cursor='✔',
            menu_highlight_style=style,
            multi_select=True,
            show_multi_select_hint=True,
            cycle_cursor=True,
            clear_screen=True,
        )

    def start(self) -> None:
        """
        Starts the main menu loop
        """
        menu_exit = False
        while not menu_exit:
            selection = self.menu.show()

            try:
                self.switch[selection][1]()
            except:
                menu_exit = True
