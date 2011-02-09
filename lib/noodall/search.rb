module Noodall
  module Search
    #STOPWORDS = ["about", "above", "above", "across", "after", "afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also", "although", "always", "among", "amongst", "amoungst", "amount", "and", "another", "any", "anyhow", "anyone", "anything", "anyway", "anywhere", "are", "around", "back", "became", "because", "become", "becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom", "but", "call", "can", "cannot", "cant", "con", "could", "couldnt", "cry", "describe", "detail", "done", "down", "due", "during", "each", "eight", "either", "eleven", "else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except", "few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further", "get", "give", "had", "has", "hasnt", "have", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him", "himself", "his", "how", "however", "hundred", "inc", "indeed", "interest", "into", "its", "itself", "keep", "last", "latter", "latterly", "least", "less", "ltd", "made", "many", "may", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much", "must", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "nobody", "none", "noone", "nor", "not", "nothing", "now", "nowhere", "off", "often", "once", "one", "only", "onto", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own", "part", "per", "perhaps", "please", "put", "rather", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show", "side", "since", "sincere", "six", "sixty", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system", "take", "ten", "than", "that", "the", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon", "these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "together", "too", "top", "toward", "towards", "twelve", "twenty", "two", "under", "until", "upon", "very", "via", "was", "well", "were", "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves"]
    STOPWORDS=["a", "about", "above", "across", "after", "again", "against", "all", "almost", "alone", "along", "already", "also", "although", "always", "among", "an", "and", "another", "any", "anybody", "anyone", "anything", "anywhere", "are", "area", "areas", "around", "as", "ask", "asked", "asking", "asks", "at", "away", "b", "back", "backed", "backing", "backs", "be", "became", "because", "become", "becomes", "been", "before", "began", "behind", "being", "beings", "best", "better", "between", "big", "both", "but", "by", "c", "came", "can", "cannot", "case", "cases", "certain", "certainly", "clear", "clearly", "come", "could", "d", "did", "differ", "different", "differently", "do", "does", "done", "down", "down", "downed", "downing", "downs", "during", "e", "each", "early", "either", "end", "ended", "ending", "ends", "enough", "even", "evenly", "ever", "every", "everybody", "everyone", "everything", "everywhere", "f", "face", "faces", "fact", "facts", "far", "felt", "few", "find", "finds", "first", "for", "four", "from", "full", "fully", "further", "furthered", "furthering", "furthers", "g", "gave", "general", "generally", "get", "gets", "give", "given", "gives", "go", "going", "good", "goods", "got", "great", "greater", "greatest", "group", "grouped", "grouping", "groups", "h", "had", "has", "have", "having", "he", "her", "here", "herself", "high", "high", "high", "higher", "highest", "him", "himself", "his", "how", "however", "i", "if", "important", "in", "interest", "interested", "interesting", "interests", "into", "is", "it", "its", "itself", "j", "just", "k", "keep", "keeps", "kind", "knew", "know", "known", "knows", "l", "large", "largely", "last", "later", "latest", "least", "less", "let", "lets", "like", "likely", "long", "longer", "longest", "m", "made", "make", "making", "man", "many", "may", "me", "member", "members", "men", "might", "more", "most", "mostly", "mr", "mrs", "much", "must", "my", "myself", "n", "necessary", "need", "needed", "needing", "needs", "never", "new", "new", "newer", "newest", "next", "no", "nobody", "non", "noone", "not", "nothing", "now", "nowhere", "number", "numbers", "o", "of", "off", "often", "old", "older", "oldest", "on", "once", "one", "only", "open", "opened", "opening", "opens", "or", "order", "ordered", "ordering", "orders", "other", "others", "our", "out", "over", "p", "part", "parted", "parting", "parts", "per", "perhaps", "place", "places", "point", "pointed", "pointing", "points", "possible", "present", "presented", "presenting", "presents", "problem", "problems", "put", "puts", "q", "quite", "r", "rather", "really", "right", "right", "room", "rooms", "s", "said", "same", "saw", "say", "says", "second", "seconds", "see", "seem", "seemed", "seeming", "seems", "sees", "several", "shall", "she", "should", "show", "showed", "showing", "shows", "side", "sides", "since", "small", "smaller", "smallest", "so", "some", "somebody", "someone", "something", "somewhere", "state", "states", "still", "still", "such", "sure", "t", "take", "taken", "than", "that", "the", "their", "them", "then", "there", "therefore", "these", "they", "thing", "things", "think", "thinks", "this", "those", "though", "thought", "thoughts", "three", "through", "thus", "to", "today", "together", "too", "took", "toward", "turn", "turned", "turning", "turns", "two", "u", "under", "until", "up", "upon", "us", "use", "used", "uses", "v", "very", "w", "want", "wanted", "wanting", "wants", "was", "way", "ways", "we", "well", "wells", "went", "were", "what", "when", "where", "whether", "which", "while", "who", "whole", "whose", "why", "will", "with", "within", "without", "work", "worked", "working", "works", "would", "x", "y", "year", "years", "yet", "you", "young", "younger", "youngest", "your", "yours", "z"]

    def self.configure(model)
      require 'lingua/stemmer'

      model.class_eval do
        key :_keywords, Array, :index => true
        attr_accessor :relevance

        before_save :_update_keywords
      end
    end

    module ClassMethods
      def searchable_keys(*keys)
        @searchable_keys ||= Set.new
        @searchable_keys += keys

        @searchable_keys
      end

      def language(lang = 'en')
        @language ||= lang
      end

      def stemmer
        @stemmer ||= Lingua::Stemmer.new(:language => language)
      end

      def search(query, options = {})
        if options[:per_page] || options[:per_page]
          per_page      = options.delete(:per_page)
          page          = options.delete(:page)
        end
        plucky_query = query(options.reverse_merge(
          :order => 'relevance DESC'
        ))
        criteria = plucky_query.criteria.to_hash
        options = plucky_query.options.to_hash

        # Extract words from the query and clean up
        words = query.downcase.split(/\W/) - STOPWORDS
        words.reject!{|w| w.length < 3}

        # add stemmed words to the array of words
        words = stem(words) | words

        criteria.merge!( :_keywords => { :$in => words } )

        # The Search result
        search_result = collection.map_reduce(search_map(words), search_reduce, :query => criteria)

        # Add value to sort options because model is stored in the value key
        options[:sort].map! do |s,v|
          ["value.#{s}",v]
        end

        search_query = Plucky::Query.new(search_result, options)

        if per_page
          results = search_query.paginate(:per_page => per_page, :page => page)
        else
          results = search_query.all
        end
        # clean up tmp collection
        search_result.drop
        #return results mappped to objects
        results.tap do |docs|
          docs.map! { |hash| load(hash['value']) }
        end
      end

      def stem(words)
        words.map { |word| stemmer.stem(word) }
      end

      def search_map(words)
        #convert words into Regex OR
        q = words.map do |k|
          Regexp.escape(k)
        end.join("|")
        "function(){" +
          "this.relevance = this._keywords.filter(" +
          "function(z){" +
          "return String(z).match(/(#{q})/i);" +
          "}).length;" +
          "emit(this._id, this);" +
          "}"
      end

      def search_reduce
        "function( key , values ){return values[0];}"
      end

      def search_finalize
        "function( key , values ){return values.model;}"
      end
    end

    module InstanceMethods
      protected
      def _update_keywords
        self._keywords = []

        self.class.searchable_keys.each do |search_key|
          self._keywords += keywords_for_value(send(search_key)).compact
        end
      end

      private
      def keywords_for_value(val)
        if val.kind_of?(String)
          words = val.downcase.split(/\W/) - STOPWORDS
          words.reject!{|w| w.length < 3}
          words.map do |word|
            stem = self.class.stemmer.stem(word)
            if stem != word
              [stem, word]
            else
              word
            end
          end.flatten
        elsif val.kind_of?(Array)
          val.map { |e| keywords_for_value(stemmer, e) }.flatten
        else
          [val]
        end
      end
    end
  end
end
