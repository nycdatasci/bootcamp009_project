# Introduction:
* as electronic music continues to grow (discogs stats on increased releases), the popularity of the genre has led to inflated prices in resale markets.
* I decided to explore trends to see if:
    * do certain subgenre's have higher resale prices
    * are certain markets cheaper for buying records?
    * are there any trends in what's hot and what's not:
        * by label
        * by subgenre
        * by how long a label has been around
        * "unknown artist"
        * by artist's name`
        *

## Stores Scraped:
* https://www.deejay.de
* https://www.decks.de
* redeyerecords.co.uk
* juno.co.uk
* yoyaku.io

## APIs Used
* discogs

## Phase 1 Features:
* Scrape each store and create a db of pertinent release information
* Compare prices and availability to determine which sites are cheaper

## Phase 2 Features:
* Using discogs API, search and filter labels, artists, releases and receive price comparable for each site.
* Using discogs marketplace prices, find records that have a higher 3rd party price vs. Retail.
* Bookmark labels, releases, artists

## Phase 3 Features:
* Receive notifications on availability of bookmarked labels , releases, and artists.
* Find trends in vinyl culture
* Using youtube views per day/rating and rating in discogs to rank popularity in 3rd party pricing

## Phase 4 Features:
* integrate discogs API to import collection and wantlist
* integrate residentadvisor information on upcoming artist events.
* scrape artist data from RA.
