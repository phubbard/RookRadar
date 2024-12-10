# RookRadar

The problem: A friend does consulting. He works at home, or sometimes in an office. He also wants to track driving time, since that is often a business expense.

The idea: use iBeacon hardware to track contexts. Place inexpensive, long-life beacons in the three locations, then build a simple app that will keep a timestamped 
log of entries and departures.

We initially considered location i.e. GPS but what he's tracking is _context_, not location - the car is mobile, he rents and may move, or change employers. Beacons handle all of that and are
more private, so if he gets a sensitive contract this doesn't disclose the office location.

Future features - upload to a portal, analytics, timecard generation / reporting.
