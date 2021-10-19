#!/usr/bin/python
import os
import re


class Engine:
    exec_list = []

    @staticmethod
    def gen_public_key():
        os.system('ssh-keygen')

    class Ansible:
        @staticmethod
        def load_scripts(os_name):
            rList = []

            scripts = os.listdir(
                path='../scripts/' + os_name)

            for script in scripts:
                rList.append(
                    {'title': script, 'type': 'command',
                     'command': Engine.Ansible.add_script}
                )
            return rList

        @staticmethod
        def add_script(name):
            if name not in Engine.exec_list:
                Engine.exec_list.append(name)
            print(Engine.exec_list)

        @staticmethod
        def get_hosts():
            rList = []

            with open('C:/Users/cmaga/OneDrive/Desktop/CCDC/scripter/test/hosts-list_1.log') as file:
                file_contents = file.read()

            for i in re.findall("\[(.*?)\]", file_contents):
                rList.append({'title': i, 'type': 'menu', 'subtitle': 'Please selection a your OS...',
                              'options': [
                                  {'title': 'windows', 'type': 'menu', 'subtitle': 'Please selection a script...',
                                      'options': Engine.Ansible.load_scripts('windows')},
                                  {'title': 'linux', 'type': 'menu', 'subtitle': 'Please selection a script...',
                                      'options': Engine.Ansible.load_scripts('linux')},
                              ]})
            return rList

        @staticmethod
        def get_ips():
            with open('C:/Users/cmaga/OneDrive/Desktop/CCDC/scripter/test/hosts-list_1.log') as file:
                file_contents = file.read()

            read_data = file_contents.split('[')

            for i, j in enumerate(read_data):
                read_data[i] = "[" + read_data[i]

            print(read_data)


# Engine.Ansible.get_ips()
