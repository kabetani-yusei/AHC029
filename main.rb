#入出力用のクラス
class Project
  attr_accessor :h, :v
  
  def initialize(h, v)
    @h = h
    @v = v
  end
end

class CardType
  WORK_SINGLE = 0
  WORK_ALL = 1
  CANCEL_SINGLE = 2
  CANCEL_ALL = 3
  INVEST = 4
end

class Card
  attr_accessor :t, :w, :p
  #t: カードの種類
  #w: カードの価値
  #p: カードの価格
  def initialize(t, w, p)
    @t = t
    @w = w
    @p = p
  end
end

class Judge
  attr_accessor :n, :m, :k

  MAX_INVEST_LEVEL = 20

  def initialize(n, m, k)
    @n = n
    @m = m
    @k = k
  end

  #手持ちカードの読み込み
  def read_initial_cards
    cards = []
    n.times do
      t, w = gets.split.map(&:to_i)
      cards << Card.new(t, w, 0)
    end
    return cards
  end

  #手持ちのプロジェクトの読み込み
  def read_initial_projects
    projects = []
    m.times do
      h, v = gets.split.map(&:to_i)
      projects << Project.new(h, v)
    end
    return projects
  end

  def read_projects
    projects = []
    m.times do
      h, v = gets.split.map(&:to_i)
      projects << Project.new(h, v)
    end
    return projects
  end

  #1ターン目の行動
  def use_card(c, m)
    puts "#{c} #{m}"
    $stdout.flush
  end

  #現在の金額の読み込み
  def read_money
    gets.to_i
  end

  #カード候補の読み込み
  def read_next_cards
    cards = []
    k.times do
      t, w, p = gets.split.map(&:to_i)
      cards << Card.new(t, w, p)
    end
    return cards
  end

  #次のカードの選択
  def select_card(r)
    puts r
    $stdout.flush
  end

  #コメントアウト用
  def comment(message)
    puts "# #{message}"
  end
end



class Visualizer
  attr_accessor :n, :m, :k, :t

  MAX_INVEST_LEVEL = 20

  def initialize(n, m, k, t)
    @n = n
    @m = m
    @k = k
    @t = t

    #visualizer用の変数
    #状態変数
    @invest_level = 0
    @money = 0
    @turn = 0
    @use_card_i = 0
    @wait_project_i = 0
    #初期状態
    @initial_cards = []
    @initial_projects = []
    #待ち状態
    @waiting_cards = []
    @waiting_projects = []
    #現在の状態
    @cards = []
    @projects = []

    #プロジェクトの読み込み
    #初期
    m.times do
      h, v = gets.split.map(&:to_i)
      @initial_projects << Project.new(h, v)
      @projects << Project.new(h, v)
    end
    #待ち
    (t*m).times do
      h, v = gets.split.map(&:to_i)
      @waiting_projects << Project.new(h, v)
    end
    #カードの読み込み
    #初期
    n.times do
      a, b = gets.split.map(&:to_i)
      @initial_cards << Card.new(a, b, 0)
      @cards << Card.new(a, b, 0)
    end
    #待ち
    t.times do
      waiting_cards_temp = []
      k.times do
        a, b, c = gets.split.map(&:to_i)
        waiting_cards_temp << Card.new(a, b, c)
      end
      @waiting_cards << waiting_cards_temp
    end
  end

  #手持ちカードの読み込み
  def read_initial_cards
    return @initial_cards
  end

  #手持ちのプロジェクトの読み込み
  def read_initial_projects
    return @initial_projects
  end

  #カードの使用
  def use_card(c, d)
    #手持ちカードのc番目を、m番目に対して使う
    @use_card_i = c
    puts "#{c} #{d}"
    if @cards[c].t == CardType::WORK_SINGLE
      if @projects[d].h - @cards[c].w > 0
        @projects[d].h -= @cards[c].w
      else
        @money += @projects[d].v
        @projects[d] = @waiting_projects[@wait_project_i]
        weight = 2 ** (@invest_level)
        @projects[d].h *= weight
        @projects[d].v *= weight
        @wait_project_i += 1
      end
    elsif @cards[c].t == CardType::WORK_ALL
      for i in 0...m
        if @projects[i].h - @cards[c].w > 0
          @projects[i].h -= @cards[c].w
        else
          @money += @projects[i].v
          @projects[i] = @waiting_projects[@wait_project_i]
          weight = 2 ** (@invest_level)
          @projects[i].h *= weight
          @projects[i].v *= weight
          @wait_project_i += 1
        end
      end
    elsif @cards[c].t == CardType::CANCEL_SINGLE
      @projects[d] = @waiting_projects[@wait_project_i]
      weight = 2 ** (@invest_level)
      @projects[d].h *= weight
      @projects[d].v *= weight
      @wait_project_i += 1
    elsif @cards[c].t == CardType::CANCEL_ALL
      for i in 0...m
        @projects[i] = @waiting_projects[@wait_project_i]
        weight = 2 ** (@invest_level)
        @projects[i].h *= weight
        @projects[i].v *= weight
        @wait_project_i += 1
      end
    elsif @cards[c].t == CardType::INVEST
      @invest_level += 1
    end
  end

  #現在の金額の読み込み
  def read_money
    return @money
  end

  #カード候補の読み込み
  def read_next_cards
    waiting_cards_temp = []
    @waiting_cards[@turn].each do |card|
      weight = 2 ** (@invest_level)
      waiting_cards_temp << Card.new(card.t, card.w * weight, card.p * weight)
    end
    @waiting_cards[@turn] = waiting_cards_temp.map(&:dup)
    return @waiting_cards[@turn]
  end

  def read_projects
    return @projects
  end

  #次のカードの選択
  def select_card(r)
    puts r
    card_info = @waiting_cards[@turn][r]
    @money -= card_info.p
    @cards[@use_card_i] = card_info
    @turn += 1
  end

  #コメントアウト用
  def comment(message)
    puts "# #{message}"
  end
end




#解くためのクラス
class Solver
  attr_accessor :n, :m, :k, :t, :judge

  def initialize(n, m, k, t)
    @n = n
    @m = m
    @k = k
    @t = t
    #@judge = Judge.new(n, m, k)
    @judge = Visualizer.new(n, m, k, t)
  end


  #新たに作った関数
  #手持ちのカードの種類を調べる
  def cards_kind_check
    cards_kind_list = []
    @cards.each do |card|
      cards_kind_list << card.t
    end
    return cards_kind_list
  end
  #増資カードを使えるかどうか
  def invest_level_exceed_check
    return @invest_level + cards_kind_check.count(CardType::INVEST) < Judge::MAX_INVEST_LEVEL
  end
  #最大の労働力が必要なプロジェクトを選ぶ
  def select_most_max
    max_value = 0
    max_value_project = 0
    @projects.each_with_index do |project, i|
      if project.h > max_value
        max_value = project.h
        max_value_project = i
      end
    end
    return max_value_project
  end
  #最小の労働力が必要なプロジェクトを選ぶ
  def select_most_min
    min_value = @projects[0].h
    min_value_project = 0
    @projects.each_with_index do |project, i|
      if project.h < min_value
        min_value = project.h
        min_value_project = i
      end
    end
    return min_value_project
  end



  def solve
    @turn = 0
    @money = 0
    @invest_level = 0
    @cards = @judge.read_initial_cards
    @projects = @judge.read_initial_projects

    @t.times do
      use_card_i, use_target = select_action
      if @cards[use_card_i].t == CardType::INVEST
        @invest_level += 1
      end
      @judge.comment("used #{@cards[use_card_i]} to target #{use_target}")
      @judge.use_card(use_card_i, use_target)

      #例外処理　増資カードが20回以上使われたらエラー
      raise 'Invest level exceeds maximum' unless @invest_level <= Judge::MAX_INVEST_LEVEL

      @projects = @judge.read_projects
      @money = @judge.read_money
      next_cards = @judge.read_next_cards
      select_card_i = select_next_card(next_cards)
      @cards[use_card_i] = next_cards[select_card_i]
      @judge.select_card(select_card_i)
      @money -= next_cards[select_card_i].p

      #例外処理　お金がマイナスになったらエラー
      raise 'Negative money' unless @money >= 0

      @turn += 1
    end
    #最終評価としてお金を返す
    return @money
  end


  #手持ちのカードから何を出すかを決める
  def select_action
    cards_kind = cards_kind_check
    if cards_kind.include?(CardType::INVEST) && @invest_level < Judge::MAX_INVEST_LEVEL
      return [cards_kind.index(CardType::INVEST), 0]

    elsif cards_kind.include?(CardType::WORK_ALL)
      return [cards_kind.index(CardType::WORK_ALL), 0]

    elsif cards_kind.include?(CardType::WORK_SINGLE)
      return [cards_kind.index(CardType::WORK_SINGLE), select_most_min]

    elsif cards_kind.include?(CardType::CANCEL_SINGLE)
      return [cards_kind.index(CardType::CANCEL_SINGLE), select_most_max]

    elsif cards_kind.include?(CardType::CANCEL_ALL)
      return [0, 0]
    end
  end

  #何のカードを買うかを決める
  def select_next_card(next_cards)
    #買うことができるカードのリストを作成
    buyable_cards = []
    invest_cards = []
    next_cards.each_with_index do |card, i|
      if card.p <= @money
        buyable_cards << [card.t, i] if card.t != CardType::INVEST
        invest_cards << [card.p, i] if card.t == CardType::INVEST
      end
    end

    #増資カードを買うことができるか
    if invest_cards.size > 0 && invest_level_exceed_check
      invest_cards = invest_cards.sort_by{|x| x[0]}
      return invest_cards[0][1]
    end
    
    #それ以外の場合
    best_card_index = 0
    buyable_cards.each do |card, i|
      if card == CardType::WORK_SINGLE
        best_card_index = i
      elsif card ==CardType::WORK_ALL
        best_card_index = i
        break
      end
    end
    return best_card_index
  end
end



def main
  n, m, k, t = gets.split.map(&:to_i)
  solver = Solver.new(n, m, k, t)
  score = solver.solve
  puts "#score:#{score}"
  $stderr.puts "#score:#{score}"
end

main()