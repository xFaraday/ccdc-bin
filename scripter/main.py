#!/usr/bin/python

def main():
    from gui.ui import Menu, MultiSelectMenu
    from core.engine import Engine

    windows_options = Engine.Ansible.load_scripts("windows")
    windows = MultiSelectMenu("Serial Scripter", windows_options)

    linux_options = Engine.Ansible.load_scripts("linux")
    linux = MultiSelectMenu("Serial Scripter", linux_options)

    script_options = [("[a] Windows", windows.start),
                      ("[b] Linux", linux.start), ("[<] Go Back", print)]
    scripts = Menu("Serial Scripter", script_options, cursor="💥")

    host_options = Engine.Ansible.load_host_options(scripts)
    hosts = Menu("Serial Scripter", host_options, cursor="💥")

    ansible_options = [("[a] Scripts Transfer", print),
                       ("[b] Execute", hosts.start),
                       ("[c] Results", print),
                       ("[<] Go Back", print)
                       ]

    ansible = Menu("Serial Scripter", ansible_options, cursor="💥")

    main_options = [("[a] Ansible", ansible.start),
                    ("[b] Generate Host File List", print),
                    ("[c] Scripts", print),
                    ("[q] quit", print)
                    ]

    main = Menu("Serial Scripter", main_options, cursor="︻デ═一")
    print(type(main))
    main.start()


if __name__ == "__main__":
    main()
