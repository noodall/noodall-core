module Noodall
  class Node
    include MongoMapper::Document
    include MongoMapper::Acts::Tree
    include Canable::Ables

    plugin MongoMapper::Plugins::MultiParameterAttributes
    plugin Indexer
    plugin Search
    plugin Tagging
    plugin Noodall::GlobalUpdateTime

    key :title, String, :required => true
    key :browser_title, String
    key :name, String
    key :description, String
    key :body, String, :default => ""
    key :position, Integer, :default => nil, :index => true
    key :_type, String
    key :published_at, Time, :index => true
    key :published_to, Time, :index => true
    key :updatable_groups, Array
    key :destroyable_groups, Array
    key :publishable_groups, Array
    key :viewable_groups, Array
    key :permalink, Permalink, :required => true, :index => true
    key :admin_title, String

    timestamps!
    userstamps!

    enable_versioning

    alias_method :keywords, :tag_list
    alias_method :keywords=, :tag_list=

    # For publishing
    attr_accessor :publish, :hide

    # For re-dordering
    attr_accessor :previous_parent_id, :moved

    acts_as_tree :order => "position", :search_class => Noodall::Node

    # if there are any children that are not of an allowed template, error
    validate :child_templates_allowed

    scope :published, lambda { where(:published_at => { :$lte => current_time }, :published_to => { :$gte => current_time }) }

    # Published child Nodes of the current Node
    #
    # Returns Array containing all published child Nodes
    def published_children
      self.children.select{|c| c.published? }
    end

    # Set the Node's parent. Set to "none" to have no parent.
    #
    # parent - The String to set as parent or "none"
    #
    # Allow parent to be set to none using a string.
    # Allows us to set the parent to nil easily via forms
    def parent=(var)
      self[parent_id_field] = nil
      var == "none" ? super(nil) : super
    end

    # The template name of the Node
    #
    # Returns String the template name
    def template
      self.class.name.titleize
    end

    # Set the Node's template
    #
    # Examples
    #
    #   node = Noodall::Node.find_by_permalink('some-page-permalink')
    #   node.template = "Landing Page"
    #   node.template
    #   # => "Landing Page"
    #
    # Returns String the new template name
    def template=(template_name)
      self._type = template_name.gsub(' ','') unless template_name.blank?
    end

    # Whether this Node is published
    def published?
      !published_at.nil? and published_at <= current_time and (published_to.nil? or published_to >= current_time)
    end

    # Whether this Node has a draft
    def has_draft?
      !version_at(:latest).nil? && version_at(:latest).pos != version_number
    end

    # Whether this Node is pending publication
    def pending?
      published_at.nil? or published_at >= current_time
    end

    # Whether this Node has expired
    def expired?
      !published_to.nil? and published_to <= current_time
    end

    # Whether this is the first Node in the tree
    def first?
      position == 0
    end

    # Whether this is the last Node in the tree
    def last?
      position == siblings.count
    end

    # Moves the Node one position lower in the tree
    #
    # Examples
    #
    #   node = Noodall::Node.find_by_permalink('some-page-permalink')
    #   node.position
    #   # => 3
    #   node.move_lower
    #   node.position
    #   # => 4
    def move_lower
      sibling = search_class.first(:position => {"$gt" => self.position}, parent_id_field => self[parent_id_field], :order => 'position ASC')
      switch_position(sibling)
    end

    # Moves the Node one position higher in the tree
    #
    # Examples
    #
    #   node = Noodall::Node.find_by_permalink('some-page-permalink')
    #   node.position
    #   # => 3
    #   node.move_higher
    #   node.position
    #   # => 2
    def move_higher
      sibling = search_class.first(:position => {"$lt" => self.position}, parent_id_field => self[parent_id_field], :order => 'position DESC')
      switch_position(sibling)
    end

    #def run_callbacks(kind, options = {}, &block)
      #self.class.send("#{kind}_callback_chain").run(self, options, &block)
      #self.embedded_associations.each do |association|
        #self.send(association.name).each do |document|
          #document.run_callbacks(kind, options, &block)
        #end
      #end
      #self.embedded_keys.each do |key|
        #self.send(key.name).run_callbacks(kind, options, &block) unless self.send(key.name).nil?
      #end
    #end

    # The content of all slots
    #
    # Returns Array of Noodall::Component objects
    def slots
      slots = []
      for slot_type in self.class.possible_slots.map(&:to_s)
        self.class.send("#{slot_type}_slots_count").to_i.times do |i|
          slots << self.send("#{slot_type}_slot_#{i}")
        end
      end
      slots.compact
    end

    # All groups the Node belongs to
    #
    # Returns Array of groups
    def all_groups
      updatable_groups | destroyable_groups | publishable_groups | viewable_groups
    end

    %w( updatable destroyable publishable viewable ).each do |permission|
      define_method("#{permission}_by?") do |user|
        user.admin? or send("#{permission}_groups").empty? or user.groups.any?{ |g| send("#{permission}_groups").include?(g) }
      end

      define_method("#{permission}_groups_list") do
        send("#{permission}_groups").join(', ')
      end

      define_method("#{permission}_groups_list=") do |groups_string|
        send("#{permission}_groups=", groups_string.downcase.split(',').map{|g| g.blank? ? nil : g.strip }.compact.uniq)
      end
    end

    # Whether the supplied user can create the Node
    #
    # user - The User object to check against
    def creatable_by?(user)
      parent.nil? or parent.updatable_by?(user)
    end

    # Sibling Nodes of the current Node
    #
    # Returns Plucky::Query containing all siblings Nodes
    def siblings
      search_class.where(:_id => {:$ne => self._id}, parent_id_field => self[parent_id_field]).order(tree_order)
    end

    # Sibling Nodes of the current Node including self
    #
    # Returns Plucky::Query containing all sibling Nodes *and* the current Node
    def self_and_siblings
      search_class.where(parent_id_field => self[parent_id_field]).order(tree_order)
    end

    # Child Nodes of the current Node
    #
    # Returns Plucky::Query containing all child Nodes
    def children
      search_class.where(parent_id_field => self._id).order(tree_order)
    end

    # Whether the current page is specified in the Sitemap
    def in_site_map?
      Noodall::Site.contains?(self.permalink.to_s)
    end

    # A slug for creating the permalink
    #
    # Returns String containing the slug
    def slug
      (self.name.blank? ? self.title : self.name).to_s.parameterize
    end

    # Title which appears in the Noodall Administration (Noodall UI).
    # This should be overridden as needed in subclasses.
    #
    # Returns String containing the title
    def admin_title
      name
    end

  private

    before_save :set_admin_title
    def set_admin_title
      self.admin_title = admin_title
    end

    def switch_position(sibling)
      tmp = sibling.position
      sibling.position = self.position
      self.position = tmp

      search_class.collection.update({:_id => self._id}, self.to_mongo)
      search_class.collection.update({:_id => sibling._id}, sibling.to_mongo)

      global_updated!
    end

    def current_time
      self.class.current_time
    end

    before_validation :set_permalink
    def set_permalink
      if permalink.blank?
        # inherit the parents permalink and append the current node's .name or .title attribute
        # this code takes name over title for the current node's slug
        # this way enables children to inherit the parent's custom (user defined) permalink also
        permalink_args = self.parent.nil? ? [] : self.parent.permalink.dup
        permalink_args << self.slug unless self.slug.blank?
        self.permalink = Permalink.new(*permalink_args)
      end
    end

    before_save :set_position
    def set_position
      write_attribute :position, siblings.size if position.nil?
    end

    before_save :clean_slots

    # This method removes any uneeded modules from the object
    # modules that would otherwise remain hidden
    # if the objects class was changed
    def clean_slots

      # TODO: spec this

      slot_types = self.class.possible_slots.map(&:to_s)
      # collect all of the slot attributes
      #    (so we don't have to loop through the whole object each time)
      slots = self.attributes.select{|k,v| k =~ /^(#{slot_types.join('|')})_slot_\d+$/ }

      # for each type of slot
      for slot_type in slot_types
        # get the number of slots of this type in the (possibly new) class
        slot_count = self._type.constantize.send("#{slot_type}_slots_count").to_i

        # loop through all of the slot attributes for this type
        slots.select{|k,v| k =~ /^#{slot_type}_slot_\d+$/ }.each do |key, slot|

          index = key[/#{slot_type}_slot_(\d+)$/, 1].to_i

          # set the slot to nil
          write_attribute(key.to_sym, nil) if index >= slot_count
        end
      end
    end

    before_save :set_path
    def set_path
      write_attribute :path, parent.path + [parent._id] unless parent.nil?
    end

    before_create :inherit_permisions
    def inherit_permisions
      unless parent.nil?
        self.updatable_groups  = parent.updatable_groups
        self.destroyable_groups = parent.destroyable_groups
        self.publishable_groups = parent.publishable_groups
        self.viewable_groups = parent.viewable_groups
      end
    end

    before_update :move_check
    def move_check
      set_previous_parent if self.parent_id_changed?
      self.moved = true if self.position_changed? or self.parent_id_changed?
    end

    before_destroy :set_previous_parent #so the child list it was removed from normalises order
    def set_previous_parent
      self.previous_parent_id = self.parent_id_was
    end

    before_create :set_moved #so if it is placed at the top of list it normalises order
    def set_moved
      self.moved = true
    end

    after_save :order_siblings
    def order_siblings
      search_class.collection.update({:_id => {"$ne" => self._id}, :position => {"$gte" => self.position}, parent_id_field => self[parent_id_field]}, { "$inc" => { :position => 1 }}, { :multi => true }) if moved
      self_and_siblings.each_with_index do |sibling, index|
        unless sibling.position == index
          sibling.position = index
          search_class.collection.save(sibling.to_mongo, :safe => true)
        end
      end
      order_previous_siblings
    end

    after_destroy :order_previous_siblings
    def order_previous_siblings
      unless previous_parent_id.nil?
        search_class.where(parent_id_field => previous_parent_id).order(tree_order).each_with_index do |sibling, index|
          unless sibling.position == index
            sibling.position = index
            search_class.collection.save(sibling.to_mongo, :safe => true)
          end
        end
      end
    end

    before_save :set_published
    def set_published
      if publish
        write_attribute :published_at, current_time if published_at.nil?
        write_attribute :published_to, 10.years.from_now if published_to.nil?
      end
      if hide
        write_attribute :published_at, nil
        write_attribute :published_to, 10.years.from_now
      end
    end

    before_save :set_name
    def set_name
      self.name = self.title if self.name.blank?
    end

    # Validate that child templates (set via sub_templates) are allowed if the template is changed
    def child_templates_allowed
      unless !_type_changed? or children.empty?
        errors.add(:base, "Template cannot be changed as sub content is not allowed in this template") unless children.select{|c| !self._type.constantize.template_classes.include?(c.class)}.empty?
      end
    end

    class << self
      @@slots = []

      # Deprecated: Sets the slots for the Node.
      # Set the names of the slots that will be available to fill with components.
      # For each name new methods will be created.
      #
      # Examples
      #
      #   Noodall::Node.slots :hero, :large, :small
      #   Noodall::Node.possible_slots
      #   # => [:hero, :large, :small]
      #
      # Returns nothing.
      def slots(*args)
        warn "[DEPRECATION] `slots` is deprecated.  Please use `slot` instead."
        slots = args.map(&:to_sym).uniq

        slots.each do |s|
          slot(s)
        end
      end

      # Define a slot type and what components are allowed to be place in that
      # slot type.
      #
      # Generates methods in Noodall::Node models that allow you to set and read the
      # number of slots of the name defined
      #
      #   Noodall::Node.slot :small, Gallery, Picture
      #
      #   class NicePage < Noodall::Node
      #     small_slots 3
      #   end
      #
      #   NicePage.small_slots_count  # => 3
      #
      #   n = NicePage.new
      #   n.small_slot_0 = Gallery.new(...)
      #
      # Returns nothing
      def slot(slot_name, *allowed_components)
        if @@slots.include?(slot_name.to_sym)
          warn "[WARNING] Overriding slot definition"
        else
          @@slots << slot_name.to_sym
          puts "Noodall::Node Defined slot: #{slot_name}"
          define_singleton_method("#{slot_name}_slots") do |count|
            instance_variable_set("@#{slot_name}_slots_count", count)
            count.times do |i|
              slot_sym = "#{slot_name}_slot_#{i}".to_sym
              key slot_sym, Noodall::Component
              validates slot_sym, :slot => { :slot_type => slot_name }
              validates_associated slot_sym
            end
          end

          define_singleton_method("#{slot_name}_slot_components") do
            class_variable_get "@@#{slot_name}_slot_components".to_sym
          end

          define_singleton_method("#{slot_name}_slots_count") do
            instance_variable_get("@#{slot_name}_slots_count")
          end
        end
        class_variable_set "@@#{slot_name}_slot_components".to_sym, allowed_components
      end

      # The number of slots available to a Node
      #
      # Examples
      #
      #   ContentPage.slots_count
      #   # => 8
      #
      # Returns Fixnum the number of slots
      def slots_count
        @@slots.inject(0) { |total, slot| total + send("#{slot}_slots_count").to_i }
      end

      # All possible slots
      #
      # Examples
      #
      #   Noodall::Node.slot :large, GeneralContent
      #   Noodall::Node.slot :small, GeneralContent
      #   Noodall::Node.slot :carousel, Carousel
      #
      #   Noodall::Node.possible_slots
      #   # => [:large, :small, :carousel]
      #
      # Returns Array of Symbols
      def possible_slots
        @@slots
      end

      # Collection of all top-level Nodes (those without parent_id)
      #
      # Returns Plucky::Query containing all top level Nodes
      def roots(options = {})
        self.where(options.reverse_merge({parent_id_field => nil})).order(tree_order)
      end

      # Finds a Node by its permalink attribute
      #
      # permalink - The String permalink name to find
      #
      # Examples
      #
      #   Noodall::Node.find_by_permalink('some-page-permalink')
      #
      # Returns Noodall::Node node which was found
      def find_by_permalink(permalink)
        node = find_one(:permalink => permalink.to_s, :published_at => { :$lte => current_time })
        raise MongoMapper::DocumentNotFound if node.nil? or node.expired?
        node
      end

      # Templates classes available for use with the current Node
      #
      # Examples
      #
      #   Noodall::Node.template_classes
      #   # => [ContactPage, ContentPage, LandingPage]
      #
      #   ContentPage.template_classes
      #   # => [ContentPage, PageA, PageB]
      #
      # Returns Array of template constants
      def template_classes
        return root_templates if self == Noodall::Node
        @template_classes || []
      end

      # Templates available for use with nodes
      #
      # Examples
      #
      #   Noodall::Node.template_names
      #   # => ["Contact Page", "Content Page", "Landing Page"]
      #
      # Returns Array of template names
      def template_names
        template_classes.map{|c| c.name.titleize }.sort
      end

      # All Node template classes available in the tree (all Node templates)
      #
      # Returns Array of template class constants
      def all_template_classes
        templates = []
        root_templates.each do |template|
          templates << template
          templates = templates + template.template_classes
        end
        templates.uniq
      end

      # All Node templates available in the tree (all Node templates)
      #
      # Returns Array of template names
      def all_template_names
        all_template_classes.map{|c| c.name.titleize }.sort
      end

      # Set the Node templates that can be a child  of this templates
      # in the tree
      def sub_templates(*arr)
        @template_classes = arr
      end

      @@root_templates = []

      # Set the Node templates that can be a root of a tree
      #
      # Examples
      #
      #   Noodall::Node.root_templates Home, LandingPage
      #   Noodall::Node.root_templates
      #   # => [Home, LandingPage]
      #
      # Returns Array of the root templates
      def root_templates(*templates)
        @@root_templates = templates unless templates.empty?
        @@root_templates
      end

      # Deprecated: Please use root_templates instead
      #
      # Returns nothing
      def root_template!
        warn "[DEPRECATION] `root_template` is deprecated.  Please use `root_templates` instead."
        @@root_templates << self
      end

      # Whether the Node is a root template or not (not a sub-template)
      #
      # Examples
      #
      #   ContentPage.root_template?
      #   # => true
      def root_template?
        @@root_templates.include?(self)
      end

      # Returns a list of classes that can have this Node as a child
      def parent_classes
        all_template_classes.find_all do |c|
          c.template_classes.include?(self)
        end
      end

      # Current time
      #
      # Returns ActiveSupport::TimeWithZone or Time
      # If Rails style time zones are unavailable fallback to standard now
      def current_time
        Time.zone ? Time.zone.now : Time.now
      end
    end

    class SlotValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless value.nil? or Noodall::Component.positions_classes(options[:slot_type]).one?{|c| c.name == value._type }
          record.errors[attribute] << "cannnot contain a #{value.class.name.humanize} component"
        end
      end
    end

  end

end
