class BusTicket < ActiveRecord::Base
    self.abstract_class = true
    self.table_name = 'tickets'
    establish_connection :etn
  end