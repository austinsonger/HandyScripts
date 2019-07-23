#!/usr/bin/python

""" So I guess we have to import stuff now ... """

import os
import subprocess

def skype():

	def DOWNDMG():
		os.system('curl -Lo /tmp/Skype.dmg https://go.skype.com/mac.download')

	def MOUNT():
		os.system('hdiutil attach -noverify -nobrowse /tmp/Skype.dmg')

	def COPY():
		os.system('ditto -rsrc /Volumes/Skype/Skype.app ~/Applications/Skype.app')

	def EJECT():
		os.system('hdiutil detach /Volumes/Skype')

	def REMOVE():
		os.system('rm /tmp/Skype.dmg')

	def install():
		DOWNDMG()
		MOUNT()
		COPY()
		EJECT()
		REMOVE()

	install()

skype()
