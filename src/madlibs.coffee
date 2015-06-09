# Description
#   Plays a round of Madlibs™ - The World's Greatest Word Game.
#
# Commands:
#   madlib start - starts a new round of Madlibs
#   madlib start <number> - starts using the madlib at index of <number>
#   madlib cancel - cancels a current round of Madlibs
#   madlib (respond|r|submit|s) <response> - submits a Madlib response
#
# Notes:
#   The array Madlib#madlibs contains madlib data. Each element should be a JSON
#   object containing two attributes: 'title' and 'text'. Format your text by
#   placing blanks to be filled within double curly breaks, e.g. {{noun}}.
#
# Author:
#   benjarwar

class Madlib
  constructor: () ->
    @index = 0
    @responses = []

  madlibs: [
    {
      title: 'What is Hubot?'
      text: 'Hubot is your company\'s {{noun}}. Install him in your company to {{adverb}} improve and reduce employee efficiency. {{name of a company}}, Inc., wrote the first version of Hubot to automate our company {{noun}}. Hubot knew how to {{verb}} the site, automate a lot of {{plural noun}}, and be a source of fun in the {{noun}}. Eventually he grew to become a {{adjective}} force in {{same company name}}. But he led a {{adjective}}, messy life. So we {{verb, past tense}} him. Today\'s version of Hubot is open source, written in {{silly word}} on {{silly word}}.js, and easily deployed on platforms like {{silly word}}. More importantly, Hubot is a {{adjective}} way to share scripts between everyone\'s {{plural noun}}.'
    },
    {
      title: 'Coffeescript'
      text: 'CoffeeScript is a little language that compiles into {{silly word}}. Underneath that awkward {{adjective}} patina, JavaScript has always had a gorgeous {{noun}}. CoffeeScript is an attempt to expose the {{adjective}} parts of JavaScript in a/an {{adjective}} way. The golden rule of CoffeeScript is: "It\'s just {{silly word}}". The code compiles one-to-one into the equivalent {{noun}}, and there is no interpretation at runtime. You can {{verb}} any existing JavaScript library {{adverb}} from CoffeeScript (and vice-versa). The {{adjective}} output is readable and pretty-printed, will work in every JavaScript runtime, and tends to {{verb}} as fast or faster than the equivalent handwritten {{silly word}}.'
    },
    {
      title: 'I\'m Mad as Hell!',
      text: 'I don\'t have to tell you things are {{adjective}}. Everybody knows {{plural noun}} are bad. It\'s a depression. Everybody\'s out of work or scared of losing their {{noun}}. The dollar buys a nickel\'s worth; banks are {{verb ending in "ing"}} bust; shopkeepers keep a {{noun}} under the counter; {{plural noun}} are running wild in the street, and there\'s nobody anywhere who seems to know what to do, and there\'s no end to it. So, I want you to {{verb}} now. I want all of you to get up out of your {{plural noun}}. I want you to get up right now and go to the window, open it, and stick your {{noun}} out and yell, "I\'m as mad as {{noun}}, and I\'m not going to take this anymore!"'
    },
    {
      title: 'The Internet (via Wikipedia)',
      text: 'The Internet is a/an {{adjective}} system of interconnected computer {{plural noun}} that use the standard Internet protocol suite ({{acronym of random letters}}) to link several billion devices worldwide. It is a network of {{plural noun}} that consists of millions of private, {{adjective}}, academic, {{adjective}}, and government networks of local to global scope, {{verb, past tense}} by a broad array of electronic, wireless, and {{adjective}} networking {{plural noun}}. The Internet carries an extensive range of information resources and {{plural noun}}, such as the inter-linked {{adjective}} documents and applications of the {{adjective starting with "W"}} {{adjective starting with "W"}} {{noun starting with "W"}} (WWW), the infrastructure to support email, and peer-to-peer networks for {{verb ending in "ing"}} and {{noun}}.'
    },
    {
      title: 'A Long Time Ago',
      text: 'It is a period of {{adjective}} war. {{adjective}} spaceships, striking from a hidden {{noun}}, have won their first victory against the evil {{adjective}} Empire.  During the battle, rebel spies managed to {{verb}} secret plans to the Empire\'s ultimate weapon, the Death {{silly word}}, an armored {{adjective}} station with enough power to destroy an entire {{noun}}.  Pursued by the Empire\'s sinister agents, Princess {{name of person in room}} races home aboard her {{noun}}, custodian of the stolen {{plural noun}} that can save her people and restore freedom to the {{noun}}.'
    }
  ]

  generate: (index) ->
    if (index)
      @curMadlib = @madlibs[index]
    else
      @curMadlib = @getRandom(@madlibs)
    @parse()

  parse: ->
    @words = @curMadlib.text.match(/{{2}(.*?)}{2}/g)

  intro: ->
    @getRandom(@madlibIntros) + '\n' + 'Let\'s start with ' + @nextWord() + '!'

  nextWord: ->
    @curWordType = @words[@index]
    word = @curWordType.substring(2, @curWordType.length - 2)
    article = 'a '
    if word.indexOf('same') == 0
      article = 'the '
    else if word.substring(0,1) in @vowels
      article = 'an '
    article + word

  nextWordWithIntro: ->
    @getRandom(@wordIntros) + ' ' + @nextWord() + '!'

  submit: (response) ->
    curResponse = @responses[@index] = {}
    curResponse.wordType = @curWordType
    curResponse.submission = response
    @index += 1

  isDone: ->
    @index == @words.length

  assemble: ->
    @getRandom(@completionIntros) + ' This madlib is called "' + @curMadlib.title + '":\n' + @completedText()

  completedText: ->
    text = @curMadlib.text
    for response in @responses
      do (response) ->
        text = text.replace response.wordType, response.submission
    text

  getRandom: (array) ->
    array[Math.floor(Math.random() * array.length)]

  madlibIntros: [
    'I love madlibs!'
    'Let\'s do this!'
    'Alrighty, then!'
    'Bring on the funny!'
    'Let the madlib commence!'
    'Bring it!'
    'I\'m giggling already!'
    'Tee hee!'
  ]

  wordIntros: [
    'Give me'
    'Ok, next I need'
    'Now give me'
    'Thanks! Now I need'
    'Ha! Now'
    'Good one! Now I need'
    'Weird! Give me'
  ]

  vowels: ['a', 'e', 'i', 'o', 'u']

  completionIntros: [
    'Drum roll, please!'
    'Hhhehehe!'
    'Hilarious!'
    'I actually laughed out loud!'
    'Hahahahahaha!'
    'OMG!'
    'Nicely done!'
  ]

module.exports = (robot) ->
  if process.env.NODE_ENV == 'development'
    robot._test = { Madlib: Madlib }

  robot.hear /madlib start(\s?)(\d*)/, (msg) ->
    if robot.brain.get('madlib')
      msg.send 'Madlib already in progress!'
    else
      madlib = new Madlib
      madlib.generate(msg.match[2])
      robot.brain.set 'madlib', madlib
      msg.send madlib.intro()

  robot.hear /madlib (respond|r|submit|s) (.*)/, (msg) ->
    madlib = robot.brain.get('madlib')

    unless madlib?
      msg.send 'There\'s no madlib in progress. But I\'d *love* to play...'
      return

    madlib.submit msg.match[2]

    if madlib.isDone()
      msg.send madlib.assemble()
      robot.brain.remove 'madlib'
    else
      msg.send madlib.nextWordWithIntro()

  robot.hear /madlib (cancel|exit|stop)/, ->
    robot.brain.remove 'madlib'

