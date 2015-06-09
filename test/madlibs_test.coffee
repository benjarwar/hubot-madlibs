chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'robot listeners', ->
  beforeEach ->
    @robot =
      hear: sinon.spy()

    require('../src/madlibs')(@robot)

  it 'registers a hear listener to start a madlib', ->
    expect(@robot.hear).to.have.been.calledWith(/madlib start(\s?)(\d*)/)

  it 'registers a hear listener to respond to a madlib word request', ->
    expect(@robot.hear).to.have.been.calledWith(/madlib (respond|r|submit|s) (.*)/)

  it 'registers a hear listener to cancel a madlib', ->
    expect(@robot.hear).to.have.been.calledWith(/madlib (cancel|exit|stop)/)

  describe 'Madlib', ->
    beforeEach ->
      @madlib = new @robot._test.Madlib

    describe '#generate', ->
      beforeEach ->
        @madlib.madlibs = ['rural','clowns']
        @madlib.parse = sinon.spy()
        @madlib.getRandom = sinon.spy()

      it 'chooses a random Madlib from the madlibs array', ->
        @madlib.generate()
        expect(@madlib.getRandom).to.have.been.calledWith(@madlib.madlibs)

      it 'parses the madlib', ->
        @madlib.generate()
        expect(@madlib.parse).to.have.been.called

      it 'optionally selects the madlib at the passed in index', ->
        @madlib.generate(1)
        expect(@madlib.curMadlib).to.equal('clowns')

    describe '#parse', ->
      it 'parses out the words to replace from the madlib text', ->
        @madlib.curMadlib = {
          text: 'This is a {{test}}. It is {{only}} a {test}.'
        }
        @madlib.parse()
        expect(@madlib.words.length).to.equal(2)
        expect(@madlib.words[0]).to.equal('{{test}}')
        expect(@madlib.words[1]).to.equal('{{only}}')

    describe '#intro', ->
      beforeEach ->
        @getRandomStub = sinon.stub(@madlib, 'getRandom', -> 'Holy crap!')
        @nextWordStub = sinon.stub(@madlib, 'nextWord', -> 'an adjective')

      it 'constructs an introductory text string', ->
        intro = @madlib.intro()
        expect(intro).to.equal('Holy crap!\nLet\'s start with an adjective!')

    describe '#nextWord', ->
      beforeEach ->
        @madlib.words = ['{{noun}}','{{same name}}','{{adverb}}']

      it 'returns a next word string using the article "a" when the next word starts with a consonant', ->
        @madlib.index = 0
        nextWord = @madlib.nextWord()
        expect(nextWord).to.equal('a noun')
        expect(@madlib.curWordType).to.equal('{{noun}}')

      it 'returns a next word string using the article "the" when the next word starts with the word "same"', ->
        @madlib.index = 1
        nextWord = @madlib.nextWord()
        expect(nextWord).to.equal('the same name')
        expect(@madlib.curWordType).to.equal('{{same name}}')

      it 'returns a next word string using the article "an" when the next word starts with a vowel', ->
        @madlib.index = 2
        nextWord = @madlib.nextWord()
        expect(nextWord).to.equal('an adverb')
        expect(@madlib.curWordType).to.equal('{{adverb}}')

    describe '#nextWordWithIntro', ->
      beforeEach ->
        @getRandomStub = sinon.stub(@madlib, 'getRandom', -> 'Splendid!')
        @madlib.wordIntros = sinon.stub()
        @nextWordStub = sinon.stub(@madlib, 'nextWord', -> 'Now give me a clown')

      it 'returns a string of the next word prefixed by a random intro', ->
        nextWordWithIntro = @madlib.nextWordWithIntro()
        expect(nextWordWithIntro).to.equal('Splendid! Now give me a clown!')

    describe '#submit', ->
      beforeEach ->
        @madlib.responses = []
        @madlib.index = 0
        @madlib.curWordType = '{{noun}}'

      it 'stores the response in the responses array with its associated word type', ->
        @madlib.submit('butt')
        expect(@madlib.responses[0].wordType).to.equal('{{noun}}')
        expect(@madlib.responses[0].submission).to.equal('butt')

      it 'increments the index', ->
        @madlib.submit('poo')
        expect(@madlib.index).to.equal(1)

    describe '#isDone', ->
      beforeEach ->
        @madlib.index = 2

      it 'returns true when the index equals the number of words', ->
        @madlib.words = ['cream cheese','Neil deGrasse Tyson']
        expect(@madlib.isDone()).to.equal(true)

      it 'returns false when the index does not equal the number of words', ->
        @madlib.words = ['waffle','toilet hands','neighborly']
        expect(@madlib.isDone()).to.equal(false)

    describe '#assemble', ->
      beforeEach ->
        @getRandomStub = sinon.stub(@madlib, 'getRandom', -> 'We did it!')
        @madlib.completionIntros = sinon.stub()
        @madlib.curMadlib = { title: 'Things I Like' }
        @completedTextStub = sinon.stub(@madlib, 'completedText', -> 'Turtles.')

      it 'grabs a random completion intro', ->
        assemble = @madlib.assemble()
        expect(@getRandomStub).to.have.been.calledWith(@madlib.completionIntros)

      it 'returns the final assembled output', ->
        assemble = @madlib.assemble()
        expect(assemble).to.equal('We did it! This madlib is called "Things I Like":\nTurtles.')

    describe '#completedText', ->
      beforeEach ->
        @madlib.curMadlib = {
          title: 'Unit Tests'
          text: 'In computer programming, {{noun}} testing is a software testing method by which {{adjective}} units of source code, sets of one or more computer program modules together with associated control {{plural noun}}, usage procedures, and operating procedures, are {{verb, past tense}} to determine whether they are fit for use.'
        }
        @madlib.responses = [
          {
            wordType: '{{noun}}',
            submission: 'unit'
          },
          {
            wordType: '{{adjective}}',
            submission: 'craptastic'
          },
          {
            wordType: '{{plural noun}}',
            submission: 'neck beards'
          },
          {
            wordType: '{{verb, past tense}}',
            submission: 'derped'
          }
        ]

      it 'replaces the words with the submissions to create the completed Madlib text', ->
        completedText = @madlib.completedText()
        expect(completedText).to.equal('In computer programming, unit testing is a software testing method by which craptastic units of source code, sets of one or more computer program modules together with associated control neck beards, usage procedures, and operating procedures, are derped to determine whether they are fit for use.')

