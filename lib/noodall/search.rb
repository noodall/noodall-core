module Noodall
  module Search
    extend ActiveSupport::Concern

    STOPWORDS = ["all","also","and","any","are","been","but","can", "cannot", "cant","else","etc","for","from","get", "give","had","has","hasnt","have","inc","into","its","not","put","see","this","too","via","was","were","when","with"]


    included do
      require 'lingua/stemmer'

      key :_keywords, Array
      attr_accessor :relevance

      before_save :_update_keywords
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
        words = query.to_s.downcase.split(/\W/) - STOPWORDS
        words.reject!{|w| w.length < 3}

        # add stemmed words to the array of words
        words = stem(words) | words

        criteria.merge!( :_keywords => { :$in => words } )

        # The Search result
        search_result = collection.map_reduce(search_map(words), search_reduce, :query => criteria, :out => "#{self.collection_name}_search")

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
        words = val.gsub(/<\/?[^>]*>/, "").downcase.split(/\W/) - STOPWORDS
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
