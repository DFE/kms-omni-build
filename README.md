# Kurento for Windows

THIS IS WORK IN PROGRESS AND NOT OF ANY USE YET!

The goal is to have Kurento Media Server running on Windows.
Once working, this fork repository and the associated submodules
will be merged into the official Kurento repositories.

The work is entirely based on the bionic-gstreamer branches
of the various Kurento repositories. A backport to 6.x is
not intended.

## Prerequisites

* The port has been tested on Microsoft Windows 10 and Windows Server 2008 R2, both 64 bit variants.
* The build requires MSYS2.
* You require an account with administrator rights.
  It may work somehow without, but that has not been tested.

## Setting Up MSYS2
* Download installer MSYS2 64 bit from https://www.msys2.org/
  Note: 32 bit compilation was not tested. It may or may not work.
* If you have Cygwin also installed, make sure that the HOME environment variable on Windows
  is NOT set. MSYS2 would also use that but ssh enforces the use of /home/<user>.
* Install MSYS2 and let it finally open the terminal.
* Run: pacman -Syu
  This will update the MSYS2 core. Close the terminal window at the end, do not use exit!
* Open MSYS2 MingW 64 bit from the start menu
  Alternatively open mingw64.exe with Explorer.
* Run: pacman -Su
  This will update the remaining packages of MSYS2.
* Run: pacman -S git
  You require git to clone the Kurento repositories.

## Clone Me!

* Per ssh: git clone -b bionic-gstreamer git@github.com:DFE/kms-omni-build
* Per https: git clone -b bionic-gstreamer https://github.com/DFE/kms-omni-build.git

If you want to commit something later, do not forget to:
* git config --global user.email "you@example.com"
* git config --global user.name "Your Name"


## Setting Up the Submodules

To avoid interesting side-effects between the forked repositories and the
original ones, this fork does not use the Git submodule approach, but
it sets up the required forked repositories in the same hierarchy
as the original repository.

In the MingW console:
* cd kms-omni-build
* bin/setup-forks.sh

The forked repositories are configured as "origin".
The original repositories are configured as "upstream".

For further reading regarding forks:
* https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/working-with-forks
* https://jarv.is/notes/how-to-pull-request-fork-github/


## Installing Required MSYS2 Packages

Did I mention that this not complete, yet?

## Compiling

Nope, not there yet.

## Creating a Distribution Packages

No compilation, no distribution, right?

## Further Info

https://www.kurento.org/

## Original Repository

https://github.com/Kurento/kms-omni-build/tree/bionic-gstreamer

## License

This project is licensed under the Apacha 2.0 License - see the [LICENSE](LICENSE) file for details

## Windows Port

Windows port by: https://www.dresearch-fe.de/
Authors:
* Florian Friederici
* Andreas Zisowsky
