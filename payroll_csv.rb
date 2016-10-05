DB_CONFIG = {
  adapter: 'mysql2',
  database: 'acct_prod',
  host: 'konner.loumalnatis.com',
  username: 'root',
  password: '3nch1lada',
  pool: 1,
  timeout: 5000
} 

class KonnerPayroll < ActiveRecord::Base
  require 'csv'
  
  establish_connection DB_CONFIG  
  
  self.table_name = 'payroll_records'
  
  PAYROLL_ID = 88

  PAYROLL_KEYS = {
    id: 'payroll_id',
    store: 'store_id',
    employee_num: 'lsp_emno',
    regular_hours: 'lsp_sthr',
    overtime_hours: 'lsp_ovhr',
    tips: 'lsp_tips',
    reimburse: 'lsp_reim',
    total_sales: 'lsp_ttsl',
    charged_sales: 'lsp_chsl',
    charged_tips: 'lsp_chtp'
  }

  EARNINGS_CODES = {
    regular: 'REG',
    overtime: 'OT',
    tips: 'TIPS',
    reimburse: 'REIM',
    total_sales: 'TSALE',
    charged_sales: 'CSALE',
    charged_tips: 'CHRGE'
  }

  scope :payroll_for_id, lambda { where("payroll_id = ?", PAYROLL_ID) }
  
  def self.raw_pay_records
    CSV.generate('', {:force_quotes => true}) do |file|
      payroll_for_id.each do |record|
        store = record.store_initials
        
        (1..10).each do |i|
          if record["lsp_job#{i}"].present?
            file << [record[PAYROLL_KEYS[:employee_num]], 'E', EARNINGS_CODES[:regular], record["lsp_std#{i}"], nil, record["lsp_rat#{i}"], nil, store, record["lsp_dep#{i}"]]
          end

          if record["lsp_ovr#{i}"] > 0
            file << [record[PAYROLL_KEYS[:employee_num]], 'E', EARNINGS_CODES[:overtime], record["lsp_ovr#{i}"], nil, record["lsp_rat#{i}"], nil, store, record["lsp_dep#{i}"]]
          end
        end

        if record[PAYROLL_KEYS[:reimburse]] > 0
          file << [record[PAYROLL_KEYS[:employee_num]], 'E', EARNINGS_CODES[:reimburse], nil, record[PAYROLL_KEYS[:reimburse]], nil, nil, store]
        end

        if record[PAYROLL_KEYS[:total_sales]] > 0
          file << [record[PAYROLL_KEYS[:employee_num]], 'D', EARNINGS_CODES[:total_sales], nil, record[PAYROLL_KEYS[:total_sales]], nil, nil, store]
        end

        if record[PAYROLL_KEYS[:charged_sales]] > 0
          file << [record[PAYROLL_KEYS[:employee_num]], 'D', EARNINGS_CODES[:charged_sales], nil, record[PAYROLL_KEYS[:charged_sales]], nil, nil, store]
        end

        if record[PAYROLL_KEYS[:charged_tips]] > 0
          file << [record[PAYROLL_KEYS[:employee_num]], 'D', EARNINGS_CODES[:charged_tips], nil, record[PAYROLL_KEYS[:charged_tips]], nil, nil, store]
        end
      end
      file
    end
  end
  
  def store_initials
    Store::Location.find_by_store_number(self[PAYROLL_KEYS[:store]]).initials
  end
end