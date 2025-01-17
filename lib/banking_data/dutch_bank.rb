require 'active_support/core_ext/object/blank'

class BankingData::DutchBank < BankingData::Bank
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods

  LOCALE = :nl

  attr_accessor :blz, :bic, :name

  class << self

    delegate :where, :only, to: :query
    delegate :map, :each, to: :all

    def all
      @@all ||= get_all
    end

    private

    def get_all
      banks = []
      SmarterCSV.process(file, opts).each do |line|
        blz = line[:identifier].to_s
        bic = line[:bic]
        name = line[:naam_betaaldienstverlener].to_s
        if blz && bic && name
          banks << new(name: name, blz: blz, bic: bic)
        end
      end
      banks.uniq
    end

    private

    def file
      File.dirname(__FILE__) +
        '/../../data/BIC-lijst-NL.csv'
    end

    def opts
      {
        col_sep: ',',
        skip_lines: 1
      }
    end
  end
end
