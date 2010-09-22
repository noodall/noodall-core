module Noodall
  module Search
    STOPWORDS = ["about", "above", "above", "across", "after", "afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also", "although", "always", "among", "amongst", "amoungst", "amount", "and", "another", "any", "anyhow", "anyone", "anything", "anyway", "anywhere", "are", "around", "back", "became", "because", "become", "becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom", "but", "call", "can", "cannot", "cant", "con", "could", "couldnt", "cry", "describe", "detail", "done", "down", "due", "during", "each", "eight", "either", "eleven", "else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except", "few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further", "get", "give", "had", "has", "hasnt", "have", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him", "himself", "his", "how", "however", "hundred", "inc", "indeed", "interest", "into", "its", "itself", "keep", "last", "latter", "latterly", "least", "less", "ltd", "made", "many", "may", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much", "must", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "nobody", "none", "noone", "nor", "not", "nothing", "now", "nowhere", "off", "often", "once", "one", "only", "onto", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own", "part", "per", "perhaps", "please", "put", "rather", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show", "side", "since", "sincere", "six", "sixty", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system", "take", "ten", "than", "that", "the", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon", "these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "together", "too", "top", "toward", "towards", "twelve", "twenty", "two", "under", "until", "upon", "very", "via", "was", "well", "were", "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves"]
  
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
        @@searchable_keys ||= Set.new
        @@searchable_keys += keys
  
        @@searchable_keys
      end
  
      def language(lang = 'en')
        @language ||= lang
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
  
        # Add the quert as a regular expression
        q = query.to_s.gsub(/[^a-z0-9 _\']+/i,' ').downcase.split.map do |k|
          Regexp.escape(k)
        end.join("|")
        criteria.merge!( :_keywords => /(#{q})/i )
  
        # The Search result
        search_result = collection.map_reduce(search_map(q), search_reduce, {:query => criteria, :finalize => search_finalize})
        # Add value to sort options because model is stored in the value key
        options[:sort].map! do |s,v|
          ["value.#{s}",v]
        end
        # If per page is set do pagination
        if per_page
          total_entries = search_result.find({}, options.dup ).count # Need to dup as the find method affects the options
          pagination = MongoMapper::Plugins::Pagination::Proxy.new(total_entries, page, per_page)
          options.merge!(:limit => pagination.limit, :skip => pagination.skip)
          pagination.subject = search_result.find({}, options ).to_a.map { |hash| load(hash['value']) }
          search_result.drop # clean up tmp collection
          pagination
        else
          results = search_result.find({}, options ).to_a.map { |hash| load(hash['value']) }
          search_result.drop # clean up tmp collection
          results
        end
      end
  
      def search_map(q)
        "function(){" +
          "this.relevance = this._keywords.filter(" +
          "function(z){" +
          "return String(z).match(/(#{q})/);" +
          "}).length;" +
          "emit(this._id, this);" +
          "}"
      end
  
      def search_reduce
        "function( key , values ){return { model: values[0]};}"
      end
  
      def search_finalize
        "function( key , values ){return values.model;}"
      end
    end
  
    module InstanceMethods
      protected
      def _update_keywords
        s = Lingua::Stemmer.new(:language => self.class.language)
  
        self._keywords = []
  
        self.class.searchable_keys.each do |search_key|
          self._keywords += keywords_for_value(s, send(search_key)).compact
        end
      end
  
      private
      def keywords_for_value(stemmer, val)
        if val.kind_of?(String)
          words = val.downcase.split(/\W/) - STOPWORDS
          words.reject!{|w| w.length < 3}
          words.map do |word|
            stem = stemmer.stem(word)
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
