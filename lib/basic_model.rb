$: << File.dirname(__FILE__)
require 'couchrest'
require 'duck_punches/time'
require 'duck_punches/date_time'
require 'duck_punches/date'

##
# A minimal class to help use CouchDB and CouchRest with Rails.
#
# Provides dot notation access for all attributes, one level deep.
#
#   note.title
#   # Instead of
#   note['title']
#
# You should subclass this so routes are properly generated when making forms.
#
#   class Note < BasicModel; end
#
#   note       = Note.new('my_db_name')
#
#   note       = Note.find('my_db_name', '4b463a09321e223b5a7aa1034e28e125')
#   result     = note.save(params[:note])
#
#   notes       = Note.view('my_db_name', 'notes/by_title-map', :key => 'Restaurant')
#   results     = notes.rows
#
# Subclasses can implement two methods:
#
#   default_attributes() # Should return a hash that all instances will be
#                        # initialized with.
#   on_update()          # Called just before a model is written to the DB.

class BasicModel
  VERSION = '0.1.0'

  attr_accessor :attributes

  def self.db(database_name)
    full_url_to_database = database_name
    if full_url_to_database !~ /^http:\/\//
      full_url_to_database = "http://localhost:5984/#{database_name}"
    end
    database = CouchRest.database!(full_url_to_database)
    if Rails.env == 'development'
      # Synchronize views in development.
      # Assumes existence of "couchdb_views" directory.
      file_manager = CouchRest::FileManager.new(File.basename(full_url_to_database))
      file_manager.push_views(File.join(Rails.root, "couchdb_views"))
    end
    database
  end

  def db
    self.class.db(@database_name)
  end

  def initialize(database_name, attributes={})
    @database_name = database_name
    @attributes    = default_attributes.merge(attributes)
  end

  ##
  # To be overridden by subclasses.

  def default_attributes
    {}
  end

  ##
  # Finds a document by ID and turns it into something
  # usable with Rails.
  #
  #   note = Note.find('my_db_name', '283934927362')
  #   note.id
  #   note._rev
  #   note.new_record?
  #   note.title # Any field from the record

  def self.find(database_name, id)
    new(database_name, self.db(database_name).get(id))
  end

  ##
  # Takes a set of results from a CouchRest view call and turns the
  # rows into Rails-friendly objects.
  #
  #   notes = Note.view('my_db_name', 'notes/by_title')
  #   notes.rows.each {|row| row.id ... }

  def self.view(database_name, view_name, options={})
    results = new(database_name, self.db(database_name).view(view_name, options))
    results.rows.each_with_index do |row, index|
      results.rows[index] = new(database_name, row['value'])
    end
    results
  end

  ##
  # Merges attributes with the existing record and saves to CouchDB.
  #
  # If attributes has an "attachment" field, it will be read and
  # formatted for inclusion as a CouchDB attachment to the document.

  def save(attributes={})
    @attributes = @attributes.merge(attributes)
    handle_attachments
    self.type = self.class.name
    if new_record?
      self.created_at = Time.now
    end
    self.updated_at = Time.now
    self.on_update if self.respond_to?(:on_update)
    result = self.class.db(@database_name).save(@attributes)
    self._rev = result['rev']
    self
  end

  ##
  # Returns the ID so Rails can use it for forms.

  def id
    _id rescue nil
  end
  alias_method :to_param, :id

  def new_record?
    (_rev).nil?
  rescue NameError
    true
  end

  ##
  # Handles getters and setters for the first level of the hash.
  #
  #   record._rev
  #   record.title
  #   record.title = "Streetside bratwurst vendor"

  def method_missing(method_symbol, *arguments)
    method_name = method_symbol.to_s

    case method_name[-1..-1]
    when "="
      @attributes[method_name[0..-2]] = arguments.first
    when "?"
      @attributes[method_name[0..-2]] == true
    else
      # Returns nil on failure so forms will work
      @attributes.has_key?(method_name) ? @attributes[method_name] : nil
    end
  end

  private

  def handle_attachments
    # Save an attachment
    if @attributes['attachment'].is_a?(ActionController::UploadedTempfile)
      attachment = @attributes.delete("attachment")
      @attributes["_attachments"] ||= {}
      filename = File.basename(attachment.original_filename)
      @attributes["_attachments"][filename] = {
        "content_type" => attachment.content_type,
        "data" => attachment.read
      }
    else
      @attributes.delete("attachment")
    end
  end

end
