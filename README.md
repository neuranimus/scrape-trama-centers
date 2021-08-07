#### Trama Centers Scraper

This scrapes the American College of Surgeons website for all current trauma centers
and outputs the contents to a single csv file.

This script was written for ruby-2.6.6 (but many other versions likely work fine).
These instructions assume you already have ruby installed.

To use this script, first install the dependencies via:

    bundle install

The run the script via

    ruby run.rb

If everything works correctly, you should now have a list of trauma centers in `<TODAYS_DATE>-centers.csv`
