#! /usr/bin/env bash

# Installs App Store software.

if ! command -v mas > /dev/null; then
  printf "ERROR: Mac App Store CLI (mas) can't be found.\n"
  printf "       Please ensure Homebrew and mas (i.e. brew install mas) have been installed first."
  exit 1
fi

# 1Password
mas install 443987910

# Acorn
mas install 1019272813

# AquaPath
mas install 424425207

# Bear
mas install 1091189122

# Cocoa JSON Editor
mas install 442160773

# Contrast
mas install 1254981365

# DaisyDisk
mas install 411643860

# Fantastical
mas install 975937182

# GarageBand
mas install 682658836

# Gifox
mas install 1082624744

# iMovie
mas install 408981434

# iPhoto
mas install 408981381

# Kaleidoscope
mas install 587512244

# Key Codes
mas install 414568915

# Keymou
mas install 449863619

# Keynote
mas install 409183694

# Kindle
mas install 405399194

# Leech
mas install 1101735327

# Marked 2
mas install 890031187

# Medis
mas install 1063631769

# MoneyWell
mas install 404246493

# Moom
mas install 419330170

# Name Mangler
mas install 603637384

# Numbers
mas install 409203825

# OmniFocus 3
mas install 1346203938

# OmniOutliner
mas install 404478020

# Pages
mas install 409201541

# Patterns
mas install 429449079

# PDFpenPro
mas install 403758325

# Pixelmator
mas install 407963104

# Shush
mas install 496437906

# Slack
mas install 803453959

# Sip
mas install 507257563

# Tweetbot
mas install 557168941

# WiFi Explorer
mas install 494803304