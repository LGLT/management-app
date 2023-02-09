# load csv file

require 'csv'

# load external csv uri file 
# and store in object the transporter keys with the given csv row


transporter_keys = {}


CSV.foreach("transporters.csv", headers: true) do |row|
    transporter_keys["000" + row["Operaci\xC3\xB3n"]] = row
end

# Retrieve all the transactions from the given transporter keys in active record
# and create a new csv file that injects metadata info to each row
CSV.open("transactions.csv", "w") do |csv|
    # add headers to csv file
    csv << transporter_keys.values.first.to_hash.keys + ["ticket_id"]

    # iterate over the transporter keys in groups of 100
    transporter_keys.keys.in_groups_of(100).map(&:compact).each do |keys|
        BusTicket.where(transporter_key: keys).each do |ticket|
            csv << transporter_keys[ticket.transporter_key].to_hash.values + [ticket.id]
        end
    end
end    
