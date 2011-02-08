# dockrw

Read and write to the Mac OS X dock from the command-line.

## Abilities:

1. List items in the Dock by their path
2. Add an application to the dock
3. Remove an application from the dock

## Usage

As a command-line utility, you have to know how to use this.

    Usage: dockrw [--option [parameter]]
    Options:
    --list          lists all dock items and their paths
    --add path      adds an application at path to the dock
    --delete index  removes the application at an index

## Installation

To install simply run this in terminal while your pwd is
in the applications build folder:

    sudo cp dockrw /usr/bin/

In other terms, all you need to do is put dockrw in /usr/bin

## Examples

Here are some usage examples:

	$ dockrw --list
	$ dockrw --add /Applications/Mail.app
	$ dockrw --delete 0

