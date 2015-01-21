# Free/busy Availability Check

This script checks whether [Zonio 3e Calendar Server](https://zonio.net/calendar/) can get availability of someone identified by email address.

## Usage

Run `availability.rb` and send email addresses on standard input separated by new line:

    ./availability.rb < EMAILS

The result is an email address on standard error. And `OK` or `NOK`
whether busy-time information is available. The email addresses on standard error are separated by space. The results are separated by new line. However, without any redirect it forms nice output:

    jon.doe@example.com OK
    foo@bar.net NOK

## Requirements

- [Rubinius](http://rubini.us) 2.5.0
- Zonio 3e Calendar cloud account (you change the source code and then any [EEE](https://zonio.net/docs/display/3E/Easy+Event+Exchange+protocol) server will do)
- [`.netrc`](http://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-File.html) file with your account credentials
- at least one email address to check

## Preparation

1. Close this repository
2. Run `bundle install`

## Motivation

This is partially an exercise in [Rubinius Actors](http://rubini.us/doc/en/systems/concurrency/). I realize this particular task should use concurrency strategy. I'll probably rewrite this script later to be more efficient. For now, it is just fun.

In general, if care about future of Ruby on new computing frontiers, you should check out [Rubinius X](http://x.rubini.us).

## License

Copyright © 2015 Filip Zrůst

Distributed under the MIT License.
