# Hubot Madlibs

A hubot script for playing Madlibs with your Hubot.

## Installation

In hubot project repo, run:

`npm install hubot-madlibs`

Then add **hubot-madlibs** to your `external-scripts.json`:

```json
[
  "hubot-madlibs"
]
```

## Commands

```madlib start``` - starts a new round of Madlibs<br />
```madlib start <number>``` - starts using the madlib at index of <number><br />
```madlib cancel``` - cancels a current round of Madlibs<br />
```madlib (respond|r|submit|s) <response>``` - submits a Madlib response<br />

## Customization

The array Madlib#madlibs contains madlib data. Each element should be a JSON
object containing two attributes: 'title' and 'text'. Format your text by
placing blanks to be filled within double curly breaks, e.g. {{noun}}.

