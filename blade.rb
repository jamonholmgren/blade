# To run game:  `ruby blade.rb`
# To run tests: `ruby blade.rb test`

class Game
  attr_reader :data

  def self.start
    new.start
  end

  def self.test
    # Create new game instances for every test
    new.send(:test_game_a)
    new.send(:test_game_b)
  end

  def initialize
    @data = {}
  end

  def start
    go :intro
    loop { step }
  end

  def step(opts={})
    @data[:test_answer] = opts[:test_answer]
    send @data[:location]
  end

  def intro
    † "–" * 34
    † "Thundershowers of Blademasters"
    † "Copyright © 1994 Jamon A. Holmgren"
    † "–" * 34
    †
    † "(q to quit, i for inventory)"
    †
    pregnant_pause
    †
    † "Where am I? I don't understand what happened. Everything is dark."
    pregnant_pause
    † "Wow, my head hurts."
    pregnant_pause
    † "Okay, I can see the faint glow from the north star. It's right in"
    † "front of me. There must be some haze in the air, because it's very"
    † "faint, and I can't see any other stars."
    pregnant_pause
    go :clearing
  end

  def clearing
    † "I'm sitting on hard rock. Is this a pathway? I can feel grass to my"
    † "right, and to my left."
    pregnant_pause
    † "Yeah, it's hard-packed rock. How did I get here?"
    pregnant_pause
    † "What do I do now?"
    †
    ask n: "North", s: "South" do |a|
      a == :n and go :cabin_outside
      a == :s and go :todo
    end
  end

  def cabin_outside
    † "In the starlight, I think I can see a cabin. It's small and has a dark"
    † "doorway and a window."
    pregnant_pause
    † "It's so quiet here. I can't hear anything but my own footsteps."
    ask g: "Go in", s: "South to clearing", n: "North" do |a|
      a == :g and go :cabin_inside
      a == :s and go :clearing
      a == :n and go :todo
    end
  end

  def cabin_inside
    † "The inside of the cabin is musty and dark. It doesn't appear to have"
    † "much at all, feeling around."
    ask g: "Go out" do |a|
      a == :g and go :cabin_outside
    end
  end

  protected

  def show_inventory
    @data[:inventory] = {
      daggers: 1,
      cloaks: 1,
    }

    puts "INVENTORY"
    puts "You are carrying: Nothing (4x)"
  end

  def leave_game
    † "It's easier to give up than to battle on. I'm so weary. I'm…"
    pregnant_pause
    print "so"
    pregnant_pause
    † " tired …"
    † "†"
    exit
  end

  def testing?
    @data[:test]
  end

  def test_answer
    a = @data[:test_answer]
    @data[:test_answer] = nil
    a
  end

  private

  def go(place)
    @data[:location] = place
  end

  def ask(questions)
    return ask_test(questions, &Proc.new) if testing?

    questions.keys.each do |k|
      puts "[#{k}] #{questions[k]}"
    end
    print "¶ #{@data[:location]} • "
    i = gets.chomp[0].to_sym
    i == :q and leave_game
    i == :i and show_inventory
    yield i
    puts ""
  end

  def ask_test(questions)
    i = test_answer
    yield i if i
  end

  def pregnant_pause(s=0.5)
    return if testing?
    sleep s
    puts ""
  end

  def †(m="")
    return m if testing?
    m.each_char { |c| print c ; sleep 0.001 }
    puts ""
  end

  # Testing

  def test_game_a
    @data[:test] = true

    go :intro
    assert data[:location], :intro
    step
    assert data[:location], :clearing
    step(test_answer: :n)
    assert data[:location], :cabin_outside
    step(test_answer: :s)
    assert data[:location], :clearing
    step(test_answer: :n)
    assert data[:location], :cabin_outside
    step(test_answer: :g)
    assert data[:location], :cabin_inside
    step(test_answer: :g)
    assert data[:location], :cabin_outside
    step

    test_summary
  end

  def test_game_b
    @data[:test] = true

    go :intro
    assert data[:location], :intro
    step
    assert data[:location], :clearing
    step(test_answer: :n)
    assert data[:location], :cabin_outside
    step(test_answer: :n)
    assert data[:location], :todo
    step

    test_summary
  end

  def answer(a)
    @data[:test_answer] = a
  end

  def assert(val, expected, m="Unexpected value #{val}, expected #{expected}")
    @passed ||= 0
    @failed ||= 0
    if val == expected
      print "•"
      @passed += 1
    else
      puts "X: #{caller[0]}: #{m}"
      @failed += 1
    end
  end

  def test_summary
    puts ""
    puts "#{@failed == 0 ? "√" : "X"} Passed: #{@passed} Failed: #{@failed}"
  end
end

if ARGV.include?("test")
  Game.test
else
  Game.start
end

