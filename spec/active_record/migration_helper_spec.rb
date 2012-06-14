require 'require_relative'
require 'active_record'

require_relative '../../lib/active_record/migration_helper'

describe ActiveRecord::MigrationHelper do
  let(:descendant) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'posts'

      extend ActiveRecord::MigrationHelper
    end
  end

  before do
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => ':memory:'
    )

    ActiveRecord::Base.connection.create_table(:posts) do |t|
      t.string(:text)
      t.string(:author)
    end
  end

  after do
    ActiveRecord::Base.connection.disconnect!
  end

  describe '::dropping' do
    subject { descendant }

    it 'should reject columns if they are going to be dropped' do
      column_names.should == [:id, :text, :author]
      subject.dropping(:text, :author)
      column_names.should == [:id]
    end

    def column_names
      subject.columns.map { |column| column.name.to_sym }
    end
  end

  describe '::renaming' do
    let(:text) { 'foo' }
    subject { descendant.new(:text => text) }

    before { ActiveRecord::Base.connection.add_column(:posts, :body, :string) }

    it 'should copy data before validation' do
      descendant.renaming(:text, :to => :body)
      subject.body.should be_nil
      subject.valid?
      subject.body.should == text
    end

    it 'should succeed if :fail_on_missing_attributes is not provided and '\
       'the from attribute is missing' do
      descendant.renaming(:foo, :to => :body)
      subject.should be_valid
    end

    it 'should succeed if :fail_on_missing_attributes is not provided and '\
       'to to attribute is missing' do
      descendant.renaming(:text, :to => :foo)
      subject.should be_valid
    end

    it 'should not succeed if :fail_on_missing_attributes is provided and '\
       'the from attribute is missing' do
      descendant.renaming(
        :foo,
        :to => :body,
        :fail_on_missing_attributes => true
      )
      subject.should_not be_valid
      subject.errors[:foo].should_not be_empty
      subject.errors[:body].should be_empty
    end

    it 'should not succeed if :fail_on_missing_attributes is provided and '\
       'the to attribute is missing' do
      descendant.renaming(
        :text,
        :to => :foo,
        :fail_on_missing_attributes => true
      )
      subject.should_not be_valid
      subject.errors[:text].should be_empty
      subject.errors[:foo].should_not be_empty
    end

    it 'should not succeed if :fail_on_missing_attributes is provided and '\
       'both attributes are missing' do
      descendant.renaming(
        :foo,
        :to => :bar,
        :fail_on_missing_attributes => true
      )
      subject.should_not be_valid
      subject.errors[:foo].should_not be_empty
      subject.errors[:bar].should_not be_empty
    end
  end
end
