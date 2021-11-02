#!/usr/bin/python
import os
import re


class Engine:
    """
    This class is a collection of classes and methods which build up
    the scripting engines core backend functionallity
    """

    @staticmethod
    def gen_public_key() -> None:
        """
        Generates an ssh key which will then be deployed to our ansible nodes
        """

        os.system('ssh-keygen')

    class Ansible:
        """
        This a class is a collection of all Ansible-related methods
        """
        @staticmethod
        def load_scripts(os_name: str) -> list:
            """
            Loads all CCDC scripts for a specified operating system

            :param str os_name: name of the desired operating scripts
            :rtype: list[tuple[int, function]]
            """

            rList = list()

            scripts = os.listdir(
                path='scripts/' + os_name)

            for script in scripts:
                rList.append(
                    (script, print)
                )
            return rList

        @staticmethod
        def load_host_options(menu) -> list:
            """
            Loads all hosts specified in the hosts-list_1.log and adds 
            them as options on the specified menu

            :param :class:'Menu<gui.ui.Menu>' menu: The menu to add our host options to
            :rtype: list[tuple[int, function]]
            """

            alphabet = 'abcdefghijklmnopqrstuvwxyz'
            rList = list()

            with open(f'{os.getcwd()}/test/hosts-list_1.log') as file:
                file_contents = file.read()

            for i, j in enumerate(re.findall("\[(.*?)\]", file_contents)):
                rList.append((f'[{alphabet[i]}] [{j}]', menu.start))

            rList.append(("[<] Go back", print))

            return rList

        @staticmethod
        def get_ips() -> list:
            """
            Parses and returns a list of all IPs from the hosts-list_1.log file

            :rtype: list[str]
            """

            with open(f'{os.getcwd()}/test/hosts-list_1.log') as file:
                file_contents = file.read()

            host_data = file_contents.split('[')

            for i, host in enumerate(host_data):
                host_data[i] = host[host.index(']')+1:]

            host_data = [i for i in host_data if i]

            return host_data
